---
layout: post
author: Chris Woodall
title: "Generate C++ Serializationg Functions Using libclang and Python"
comments: true
categories: blog
#image:
---

Recently, I was writing a set of serialization (and deserialization)
functions in C++ for a large set of structs. Each of these
serialization functions has the same basic form which requires the
programmer to manually count the number of fields and then provide the
names of the fields for serialization. All of the primitive data type
serializations were written already with a set of overloaded
function calls (for type such as: `int`, `float`, `const char *`,
`std::array<T>`, etc.). So all that needed to be handled was the
structure of the data to be serialized. I had been writing these
functions by hand, but whenever a serialized `struct` or `class` was
changed, there were a few hard to detect issues and mistakes which might arise. As an example of writing these functions, lets write an
example function for the following `struct Foo`:

```c++
struct Foo {
  uint8_t bar1;
  float   bar2;
}
```

Will have the following function.

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

As it turns out generating functions like this using macros is not
possible, since you would need a recursive macro, and templates are
also not up to the job. Rust style macros which can parse and generate
code based on the Abstract Syntax Tree (AST) would be, but this not a
native feature of C or C++. However, what if we could add it? Luckily
with `libclang` it's rather easy to generate and walk through the
Abstract Syntax Tree of a C++ file and it has official python bindings.

<!-- more -->

## Setting up the Solution

We will add a comment `//+serde(<names of serde generators>)` infront of
each `struct` or `class` we want serialized. We will call this a decorator. This will act as a flag
for our AST parser to extract the `struct` and its fields. The arguments
to `serde()` will provide different serialization templates to apply to
the `struct`. So using the struct above, the following should generate
the same output.

```c++
//+serde(my_serialization)
struct Foo {
  uint8_t bar1;
  float   bar2;
}
```

We want to extract:

1. The name of the `struct` or `class`
2. The fields of the struct including:
  - The fields name ('bar1')
  - The fields type ('uint8_t')
  - The access specifier (`public`, `protected`, or `private`)
3. Namespaces and class nesting.

## Finding the decorators

Searching for comments using `libclang` requires us to parse through all of the tokens, rather than the cursors which relate to nodes in the AST. This is because comments are striped out from the AST, but with some constraints a token can be associated to a cursor (which is what is desired for parsing the struct for its name and field information). The process looks like this:

1. Get a `TranslationalUnit` from `libclang` for the entire file being parsed.
2. Iterate through all of the tokens in the file, looking for `COMMENTS` which match the decorator string
3. Continue iterating through the tokens until a token with a matching cursor which specifies a STRUCT or CLASS declaration is found
4. Walk through the AST for that struct or class to extract the types, names and access specifiers.
  - It is also useful to walk up from the struct declaration to the root node to find all of the namespaces the struct may be inside of.
5. Repeat steps 2 to 4 until there are no more tokens left.

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
    ```
    namespace A {
    namespace B {

    class C {
        <CURSOR IS IN HERE>
    };

    }
    }
    ```

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

There are a couple of tricks to actually get `libclang` to find the standard library (and your own library files) so that it will recognize non primitive types.

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

## Conclusion

## Next Steps

[github]: https://github.com/cwoodall/cpp-serde-gen
[rust]: https://rustlang.com
