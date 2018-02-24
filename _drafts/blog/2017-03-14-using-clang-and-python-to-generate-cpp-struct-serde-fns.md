---
layout: post
author: Chris Woodall
title: "Reflection in C++ to Generate Serializable Structs Using libclang and Python"
comments: true
categories: blog
#image:
---

I have recently found myself writing a bunch of serialization (and 
deserialization) functions in C++ for some very basic structs, and 
classes. Each of these serialization functions has the same basic 
form which is basically a series of function calls to convert 
some data of some type into it's msgpack representation. As the
number of structs grows this becomes tedious and hard to upgrade. Also,
there are a few points where programmer error can result in major hard
to detect problems, if the ordering is wrong, or the number of fields
is wrong, then all bets are off. I will be the first to admit that
Google Protobufs basically solves this problem entirely by describing
the transfer messages, and datatypes in its own language and then 
compiling the target representation.

Inspired by my recent usage of [rust] I decided to see if I could create
the equivalent of rust's `#[derive()]` syntax for applying  procedural
macros to a struct. You can see my experiment on [github].

<!-- more -->

I found myself reaching for `libclang` and its python wrapper. I flirted
with the idea of doing this in Rust or Haskell; however, I work fastest
in Python and this started out as a problem I was trying to solve for 
work, so if it could not be done fast it was not useful. I did eventually
abandoned it as a work project because it complicated the build
process too much, and I figured it would become hard to maintain in its
own right in the future. Additionally, I used a python library called
cog, which makes it pretty easy to inline some python into C++ comments
and execute those actions it is actually pretty slick.

So with my toolchain in hand I ventured off into the world of AST 
parsing with libclang. So first, I have a very simple problem to
deal with. All of my structs basically look like this:

```c++
//+serde(MySerializer)
struct Foo {
  uint8_t bar1;
  float   bar2;
}
```

And generate functions looking like this:

```c++
bool my_serialization(serialization_writer *writer, Foo const &data) {
  // Add a map of length 2 to the serialization
  writer->add_map(2);

  writer->add_cstr("bar1");
  my_serialization(writer, data.bar1);

  writer->add_cstr("bar2");
  my_serialization(writer, data.bar2);

  writer->end_map();

  return writer->is_errors();
}
```

Note, the recursive use of overloaded `my_serialization()` functions, this
little design choice makes our code generation very easy, by making C++ do
some of the heavy lifting for us, we don't even need to worry about types.
For more complicated types we just need to make sure a `my_serialization()`
is implemented for them and we are off to the races. From a simple view
all I need to do is:

1. Find the structs marked for deriving the serializers.
2. Obtain the structs name (and namespace).
3. Get all of the struct or classes public fields.
  - The fields name ('bar1')
  - The fields type ('uint8_t')
  - The access specifier (`public`, `protected`, or `private`)
4. Create the serializer from a template. It is just the same thing
   over and over again.

Also, you can't just generating functions like this using macro. There
are ways to get close, but since you would need a recursive macro, it is
practically impossible. You could probably do something involving run time
reflection, or cleverness; however I wanted these to be generated at compile
time for my needs.

We will add a comment `//+serde(<names of serde generators>)` infront of
each `struct` or `class` we want serialized. This will act as a flag for 
our AST parser to extract the `struct` and its  fields. The arguments to 
`serde()` will provide different serialization templates to apply to
the `struct`. 

## Finding the decorators

Searching for comments using `libclang` requires us to parse through all of the tokens, rather than the cursors which relate to nodes in the AST. This is because comments are striped out from the AST. At first I thought this was going to be problematic; however with some constraints a token can be associated to a cursor. The token just contains information of the individual pieces of the program, while the
cursors are actually in the syntax tree. The tokens might be:

```
COMMENT: //+serde(MySerializer)
KEYWORD: struct 
IDENTIFIER: Foo 
PUNCTUATION: {
IDENTIFIER: uint8_t 
IDENTIFIER: bar1
PUNCTUATION: ;
KEYWORD: float
IDENTIFIER: bar2
PUNCTUATION: ;
PUNCTUATION: }
```

While the cursors is tree oriented and more useful for actual reflection:

```
STRUCTDECL: Foo
  - FIELD: 
    - TYPE: uint8_t
    - NAME: bar1
    - VISIBILITY: public 
  - FIELD: 
    - TYPE: float
    - NAME: bar2
    - VISIBILITY: public
```

So to find all of the `//+serde()` tags and get all of the information we need the
process is:

1. Get a `TranslationalUnit` from `libclang` for the entire file being parsed.
2. Iterate through all of the tokens in the file, looking for `COMMENTS` which match the decorator string.
3. Continue iterating through the tokens until a token with a matching cursor which specifies a STRUCT or CLASS declaration is found.
   (The first struct or class after the `//+serde()` will be parsed).
4. Walk through the AST for that struct or class to extract the types, names and access specifiers.
5. Walk up from the struct declaration to the root node to find all of the namespaces the struct may be inside of.
5. Repeat steps 2 to 4 until there are no more tokens left in the file.

So for some basic code:

```python
from serde_type import *
import clang.cindex as cl
from ctypes.util import find_library
import ccsyspath
import re

def get_current_scope(cursor):
    """
    Get the current scope of the current cursor.

    For example:
    
    namespace A {
    namespace B {

    class C {
        <CURSOR IS IN HERE>
    };

    }
    }

    will return: ["A", "B", "C"] and can be joined to be "A::B::C"

    Parameters ::
      - cursor: A clang.cindex.Cursor to loop for declaration parents of.

    Returns ::
      - A list of names of the scopes.
    """
    # Get the parent of the current cursor
    parent = cursor.lexical_parent
    # If the parent is a declartaion type then add it to the end of our scope
    # list otherwise return an empty list
    if (parent.kind.is_declaration()):
        return get_current_scope(parent) + [parent.spelling]
    else:
        return []

def find_serializable_types(tu, match_str="//\+serde\(([A-Za-z\s,_]*)\)"):
    """
    Iterate through all tokens in the current TranslationalUnit looking for comments
    which match the match_str. If the comment match look for the next struct or
    class declaration, start extracting the scope by looking at the lexical parents
    of the declaration. This will let you extract the name, then extract all of the
    fields.

    Parameters ::
        - tu: The TranslationalUnit to search over
        - match_str: The comment string to match.

    Returns ::
        - A List of SerdeRecords.
    """
    match_types = [cl.CursorKind.STRUCT_DECL, cl.CursorKind.CLASS_DECL]

    tokens = tu.cursor.get_tokens()

    found = False
    serializables = []
    serdes = []
    # iterate through all tokens, looking for the match_str in a comment. If
    # found the name, and fields are extracted from the next struct or class
    # definition. After extracting these declaration the parser continues to
    # look for more Comment otkens matching match_str.
    for token in tokens:
        match = re.match(match_str, token.spelling)
        if found:
            cursor = cl.Cursor().from_location(tu, token.location)
            if cursor.kind in match_types:
                # Extract the name, and the scope of the cursor and join them
                # to for the full C++ name.
                name = "::".join(get_current_scope(cursor) + [cursor.spelling])
                # Extract all of the fields (including access_specifiers)
                fields = [SerdeField(field.spelling, field.type.spelling,
                                     field.access_specifier.name) for field in cursor.type.get_fields()]
                serializables.append(SerdeRecord(name, fields, serdes))
                # Start searching for more comments.
                found = False
                # Clear the list of registered serdes for this Record.
                serdes = []
        elif (token.kind == cl.TokenKind.COMMENT) and match:
            serdes = [x.strip() for x in match.groups()[0].split(",")]
            found = True  # Start looking for the struct/class declaration

    return serializables
```

### Getting libclang to recognize std library types

There are a couple of tricks to actually get `libclang` to find the standard library (and your own library files) so that it will recognize non primitive types. Basically this is just making sure you invoke clang, with the proper paths to import your types. Otherwise,
the cursors will get all messed up and a bunch of errors will be thrown.

```python
def get_clang_TranslationUnit(path="t.cpp", in_args=[], in_str="", options=0):
    """
    Get the TranslationalUnit for the input fule listed:

    Parameters ::
        - path: The path of the file to parse (not read if in_str is set)
        - in_args: additional arguments to pass to clang
        - in_str: input string to parse instead of the file path.
        - options: clang.cindex.Options

    Returns ::
        - A TranslationalUnits
    """

    # Make sure we are parsing as std c++11
    args = '-x c++ --std=c++11'.split()
    # Add the include files for the standard library.
    syspath = ccsyspath.system_include_paths('clang++')
    incargs = [b'-I' + inc for inc in syspath]
    # turn args into a list of args (in_args may contain more includes)
    args = args + incargs + in_args

    # Create a clang index to parse into
    index = cl.Index.create()

    unsaved_files = None
    # If we are parsing from a string instead
    if in_str:
        unsaved_files = [(path, in_str)]
    return index.parse(path, args=args, options=options,
                       unsaved_files=unsaved_files)
```

## The Serde Engine

At this point we have all of the data we need and all we need to do is hand
it to something to generate our serializers for us. For this I created a 
registry of classes which implement functions for creating serializers and
deserializers. This is also where cog comes in. A basic example is one which
prints out the struct. The best place to see this in action is in [example-01](https://github.com/cwoodall/cpp-serde-gen/edit/master/examples/example-01.cpp.cog)

## Conclusion

This was a fun experiment, dealing with the C++ AST was a new experience for me. Though
it was rather simple, it opened up my mind to a whole world of metaprogramming and analytics
I did not previously think about. Eventually I decided this project, was more dangerous than
it was worth. All it would take is one person not to understand it for it to cause a lot of
issues, so I eventually dropped it. However, I do think there is value in knowing how to
work with `libclang`, because you can generate some very powerful analytical tools and linters
which could help an organization with very specific needs. I could also see the benefits in
compile time reflection like this; however, I think the maintenance burden would be very high.

[github]: https://github.com/cwoodall/cpp-serde-gen
[rust]: https://rustlang.com
