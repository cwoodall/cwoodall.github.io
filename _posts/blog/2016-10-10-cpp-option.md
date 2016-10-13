---
layout: post
author: Chris Woodall
title: "Error Handling: Implementing an Option&lt;T&gt; Type For Embedded C++"
date: 2016-10-10 15:30
comments: true
categories: blog
---

I have been learning [Rust][rust] lately, which has been an awesome and
rewarding experience thus far. However, at work, and on many of my embedded side
projects I use C/C++ quite extensively. But error handling ends up being
a major pain point and can make an otherwise rather simple API into a disaster.
This can be especially true if you are committed to avoiding throwing exceptions for various
performance and real-time reliability reasons. This is where Rust's model comes
in as a possibly solution (or at the very least an interesting one): the use of
the `Result<T, E>` types and the `Option<T>` type. For the time being I am going to concentrate on the `Option<T>` type and write about the `Result<T, E>` type in a future post.

The code for this blog post can be found on github as [cpp-option][github]!

<!-- more -->

### So what is this `Option<T>` thing any way?

`Option<T>` represents a value which is either a type `T` (like an `int`, `float`, or `MyFancyClass`) or `Nothing`. It is a pretty simple concept.
This makes and `Option<T>` type very good at representing the class of errors
where either you returned the correct result, *or* you just couldn't finish the
computation for some reason. To some degree this is already represented at C.
When returning a pointer you can modify that pointer to be a null pointer to
represent a failure case. This is used heavily by the C standard library and is
a brittle version of the `Option<T>` type, where checking is not enforced and
carries a high penalty. For example, for a "safe" divide operator we might do
the following:

``` c++
int *divide(int a, int b) {
  if (b==0) {
    return nullptr;
  } else {
    int *buf = new int();
    *buf = a/b;
    return buf;
  }
}

int main() {
  int *res = divide(10, 0);

  if (res != nullptr) {
    printf("%d\n", *res); // wont print
  }

  delete res;
}
```

However, now we have some dynamically allocated memory to manage, as it turns
out for cases where you need to return a pointer anyway (getting a pointer
into some datatype) this is easy to express, but in the `divide()` case it is
actually rather cumbersome. In this case it would be more natural to pass a
pointer into the divide function, and return a success value (in this case
we will use `bool`, with `true` representing a success, and `false` indicating
failure). So the following implementation would be far safer:

```c++
bool divide(int a, int b, int *c) {
  if (b == 0) {
    return false; // oh no...
  } else {
    *c = a/b;
    return true; // success!
  }
}  

int main(void) {
  int c;
  bool ret = divide(10, 0, &c);
  if (ret) {
    printf("I got a %d\n", c);
  } else {
    printf("You divided by 0... the world blew up... Thanks");
  }

  return 0;
}
```
<!-- ** -->

So what is wrong with the above solutions? The success and failure information
and the data are not bound tightly. This means that it can be easy to ignore
errors. Languages like Rust have an `Option<T>` type ([wiki][wiki-option]),
also known as `Maybe` in Haskell and `Optional` in Swift. This type would
allows one to return "something" or "nothing". You check if you have
something or nothing and then process the data accordingly. So the following
semantics become possible with a `Option<T>` type:

```c++
Option<int> divide(int a, int b) noexcept {
  if (b == 0) {
    return Nothing();
  } else {
    return a/b;
  }
}

int main(void) {
  auto result = divide(10, 0);
  if (result) { // Check that result is not Nothing
    printf("I got a %d\n", result.unwrap());
  } else {
    printf("You divided by 0... the world blew up... Thanks");
  }

  return 0;
}
```

So what are the benefits over the other divide-by-zero safe `divide()`
implementations?

1. No need to return a separate `success` or `error` type.
2. Natural calling semantics where the value being returned is the value you
   wanted to return.
3. Encourages checking, or when you don't you are explicitly bypassing the
   system by using `unwrap_unsafe` or `unwrap_or` which are easy to search for.
4. For single return functions there is no need to deal with output pointers.
   This often can make an API more intuitive.
5. For cases where we could return a nullptr, it provides a safer return type.
   With the Checking policies (explained below) if someone `unwraps()`,
   `Nothing` then a controllable action can be taken.

### So how do we implement this?

Before I continue I want to say that this type is planned to be included in
**C++17** as the `std::optional` type ([link][c++17-option]). There is also
an implementation of this type in Boost as `boost::optional`
([link][boost-option]), with some awesome work by Andrzej Krzemieński. I
highly recommend using one of these two implementations if they are available
to you! I am constrained from using C++17 or Boost in the application I want to
use this type on (embedded C++ for Cortex-M processors). There are a few other
implementations of this type in C++ one is by
[Cliff Biffle](http://cliffle.com/) and presented in his Embedded Template
Library ([Github][cbiffle-etl]). I also found the Rust inspired implementation
by simonask to be useful([Github][simonask]). I used all of these great
resources and chose to develop my own implementation to help sharpen my
understanding of C++.

#### Implementation

The full, and evolving, implementation can be found
[here](https://github.com/cwoodall/cpp-option) with examples, and unit
tests. So lets see some code, the code below implements a basic `Option<T>`
type with minimal functionality.

``` c++
struct Nothing {};

template <typename T>
class Option {
 public:
  Option() : isSomething_(false) {}

  Option(Nothing nothing) : isSomething_(false) {}

  Option(T something) : isSomething_(true), something_(something) {}

  // The copy/move functions have been left out see the github link for details.

  /**
   * An explicit conversion to bool, which makes boolean comparisons of the
   * Option type possible
   *
   * @return isSomething_ (true if it is something, false otherwise)
   */
  inline constexpr explicit operator bool(void) const { return isSomething_; }

  /**
   * Get the value stored inside of the Option<T> type
   *
   * @return something_;
   */
  inline T unwrap(void) const { return something_; }

 private:
  bool isSomething_;  ///< @brief stores whether Some(T) or Nothing is stored
  T something_;       ///< @brief temporary storage for the something object
};
```
<!-- ** -->

The class is basically just a container for a `bool` and a `T`. With semantics
for checking and getting the value if it exists. This uses C++11's `explicit`
type casting operators to create a [type-safe bool comparison][safebool] which
used to be a hassle. Now you can overload `explicit operator bool()` and allow
a custom type to be used in boolean operations, without it being able to be
compared against non-boolean types in this way (since by default almost all
types can be compared as `bool` types in C/C++). For example:

``` c++
Option<float> foo = Nothing();
if (!foo) {
  puts("Nothing\n"); // This will run
}

if (foo) {
  puts("Nothing\n"); // This wont
}

Option<float> bar = 3.14159;
if (bar) {
  printf("%f\n", bar.unwrap()); // This will run
}

if (!bar) {
  printf("This wont print");
}
```

Because it is explicit you can't just cast an Option<int> to some non-boolean type.
In fact the compiler will error and return a somewhat helpful warning.

``` c++
Option<float> foo = Nothing();

if (foo == 20) {} // wont compile

/*
 * The compiler will return the following message
 *
 * test.cc: In function ‘int main()’:
 * test.cc:7:12: error: ISO C++ forbids comparison between pointer and integer [-fpermissive]
 * if (foo == 20) {} // wont compile
 */
```

It can be convenient to be able to implicitly create an `Option<T>` without
having to specialize the template yourself. Thus, the `Some()` factory
function which can be used:

``` c++
int foo
auto bar = Some(foo); // Creates an Option<int> wrapping the value of foo.
```

Implemented very simply as:

``` c++
template <typename T>
constexpr Option<T> Some(T something) {
  return Option<T>(something);
}
```

Another interesting discovery is that when you return from a C++ function it will
pass off the return values to the constructor of the type you are returning. This makes the following syntax possible.

``` c++
Option<int> returnNothing(void) {
  return Nothing();
}

Option<int> returnSomething(void) {
  return 1;
}
```

This is rather concise, and also a rather efficient way of returning `Option<T>`'s.

So far we have one function for getting the value of a `Option<T>` with
something in it: `unwrap()`. However, the function listed above is unsafe, if
you call it on an invalid `Option<T>` it will not stop you.

I spent a while trying to figure out how to get the compiler to do what I
wanted. Which was to require that you check if an `Option<T>` was Nothing or
not. However, this does not seem possible with C++'s type system. I fell back
an approach [used by Cliff Biffle][cbiffle-etl], which uses a `Checking`
[policy][policy-pattern] system to check and trigger assertions when the system
fails. This is a clever little system which uses templates to pass types which
implement specific ways of doing things. This allows for compile-time
specialization of a type to a specific need. I was unsure where to applying
the policy. Cliff applies it to the `Option` type, but that means the library
writer chooses the checking policy, which may or not be appropriate; however,
it does create cleaner code. I decided, for now, to apply the policy to the
unwrap directly. The reason for this is so that the caller of unwrap can
determine the policy they want to follow, rather than the creator of the
`Option<T>` object. This is a little more effective for use cases where a class
might want to install its own checking policy, or an application might want to
say use a different type of assert/fault logging interface based on which
target it is being compiled for. I am still not convinced on this decision.

So lets re-write `unwrap()` to take a `CheckingPolicy`.

``` c++
template<typename T>
class Option {

...

/**
 * Get the value stored inside of the Option<T> type
 *
 * @return something_;
 */
template <typename C = AssertCheckingPolicy>
inline constexpr T unwrap(void) const {
  static_assert(std::is_base_of<CheckingPolicy, C>::value,
                "The checking policy must be derived from CheckingPolicy");
  return C::check(isSomething()), something_;
}

...

};
```
<!-- ** -->

We make the compiler enforce the `CheckingPolicy` base class, mostly so
we can give a slightly more informative error message than if the compiler
fails on `C::check()`. Below are some example policies and the
base class:

``` c++
struct CheckingPolicy {
  constexpr bool check(bool value) { return false; };
};

struct LaxCheckingPolicy : CheckingPolicy {
  static constexpr bool check(bool value) { return true; }
};

struct AssertCheckingPolicy : CheckingPolicy {
  static bool check(bool value) {
    assert(value);
    return true;
  }
};

// And you can even make it throw exceptions! This is used heavily in the unit test.
class OptionInvalidAccessException : std::exception {
  virtual const char* what() const throw() {
    return "Invalid access to Option with Nothing in it";
  }
};

struct ThrowCheckingPolicy : CheckingPolicy {
  static bool check(bool value) {
    if (!value) {
      OptionInvalidAccessException ex;
      throw ex;
    }
    return value;
  }
};
```
<!-- ** -->

So in the deeply embedded world I work it this allows for an assert, or logger,
based approach to unwrapping. This is useful since unchecked unwraps should
NOT be a normal thing, so `panic`ing is acceptable because they should be
caught and then fixed. The used of `exceptions` on invalid `unwraps()` allows
for platforms with exceptions to handle invalid unwraps sanely; After all, an
invalid `unwrap()` is exceptional while something not returning a value
might just be normal operation. However, what if you know that your function
might fail, but you have a default value you want to use. That is where
`unwrap_or()` comes in. It allows you to unwrap on success, or return some
default value if the `Option<T>` is nothing.

```c++
/**
 * Get the value stored inside of the Option<T> type or if it is Nothing()
 * then return
 *
 * @return something_;
 */
inline constexpr T unwrap_or(T or_val) const {
  return (isSomething_) ? something_ : or_val;
}

// Which allows the use of the following:

int a = divide(100, 0).unwrap_or(0); // If we get a divide by 0 error, just return 0;
```

Lets look at one more use-case.

#### Use Case Study: Read-only indexing into an aggregate data type

So let's look at a use case I have been excited about. Returning an Option type
from an aggregate datastructure which has read-only indexing.  Let's say we
have an array class `Array` which implements `Option<T> operator[](size_t i)`
for indexing into the array. If you have exceptions you can throw an exception
to indicate an out of bounds index, but if you don't you are left with unsafe
code, or clunkier semantics. So what can we express with option?

```c++
template <typename T, size_t S>
struct Array {
  T buf[S];

  Option<T> operator[](size_t i) {
    if (i < S) {
      return buf[i];
    } else {
      return Nothing();
    }
  }
};

int main() {
  Array<int, 4> foo = {1, 2, 3, 4};

  for (int i = 0; i < 10; i++) {
    auto bar = foo[i];
    if (bar) {
      auto baz = bar.unwrap();
      printf("%d: %d\n", i, baz);
    } else {
      printf("%d: out of range\n", i);
    }
  }
  return 0;
}

// Prints out:
// 0: 1
// 1: 2
// 2: 3
// 3: 4
// 4: out of range
// 5: out of range
// 6: out of range
// 7: out of range
// 8: out of range
// 9: out of range

```
<!-- ** -->

For an array this might seem a little silly; don't we want a reference or a
pointer? Probably, but there are similar data-structures where a copy might
be preferred. For example, peaking into a ring buffer for signal processing
where we can leverage `unwrap_or` very effectively, or any other datatype where
you might return something, or maybe there is nothing there... yet.

### Conclusion

This gives a nice base of functionality for an `Option<T>` class which has
clean semantics, is relatively safe and customizable, and has relatively low
overhead. This implementation of an `Option<T>` class has some flaws, and there
are some inefficiencies, but the class is rather usable for my needs at the
moment. It could be beneficial to implement some of the more functional like
features for chaining of functions which return `Option<T>`'s, which I may do
going forward, but this mostly depends on my needs. It helps with some error
handling, but what what about errors that are not so cut and dry as: is there
something or is there nothing? That is where `Result<T, E>` comes in!
Stay tuned for an implementation of `Result<T, E>`!

[policy-pattern]: http://en.wikipedia.org/wiki/Policy-based_design
[safebool]: https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Safe_bool
[github]: https://github.com/cwoodall/cpp-option
[rust]: http://rust-lang.org
[wiki-option]: https://en.wikipedia.org/wiki/Option_type
[c++17-option]: http://en.cppreference.com/w/cpp/experimental/optional
[simonask]: https://github.com/simonask/simonask.github.com/blob/master/maybe.markdown
[cbiffle-etl]: https://github.com/cbiffle/etl/blob/master/data/maybe.h
[boost-option]: http://www.boost.org/doc/libs/1_61_0/libs/optional/doc/html/index.html
