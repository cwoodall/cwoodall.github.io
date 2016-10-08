---
layout: post
author: Chris Woodall
title: "Unit Testing, and CI with C++ and Travis"
date: 2016-10-04 18:02
comments: true
categories: blog
#image:
---

While working on my [previous blog post][prev-post] on making an option type in
C++ ([github][cpp-option]) I decided to provide some unit testing, code coverage
and continuous integration support for that build. I did this partially for
myself and partially because I feel like it is the responsible thing to do when
providing a piece of code you hope other will build upon. To do this I decided
to use [Travis CI][travis-ci] for continuous integration, [cpputest][cpputest]
for unit testing, and [coveralls.io][coveralls-io] to track my code coverage. I
ran into a few roadblocks that took up some time, namely getting `C++11` support
on Travis, getting gcov to spit out the right info, and dependency management.

You can see a template project on github.com [here][template-project]

<!-- more -->

## Getting CI Working with Travis

The first road bump is always getting repeatable builds. In other languages
this is pretty straightforward, but in *C/C++* this can be a little bit of a
hassle. I used GNU Makefiles, with `gcc-4.8` and I was using C++11 features from
the beginning. You can use cmake or another build system, but the first goal is
to get repeatable builds and make sure they use the `CC` and `CXX` system
variables. This will become important later.

- [travis support][travis-ci]
  - .travis.yml
    - Rather straight forward to get started
    - Womp defaults to ubuntu 12.04 which doesn't support C++11... We need to install our own gcc-4.8 to
    make this work. Luckily this is pretty straight forward thanks to this [ppa][gcc-4.8]

## Adding Unit Tests with cpputest

- [cpputest support][cpputest]
  - Why CPPUTEST instead of GTEST?
    1. Familiarity (for me)
    2. Embedded systems development and goals
  - custom build and install script
    - [custom scripts travis][travis-ci-custom]
    - see `get-cpputest.sh`

## Adding Code Coverage with Coveralls.io

- Adding coveralls support
  - Add coveralls token as an environment value in travis
  - Get [gcov][wiki-gcov] working
    - excludes
    - proper compiler flags (makefile)
  - Use the [cpp-coveralls python library][cpp-coveralls]... And it magically works pretty well...
    - womp make sure to pass gcov-4.8

Once again the `gcc-4.8` demon strikes! We need to make sure that `gcov` uses
`gcc-4.8` too.

[prev-post]: tbd
[travis-ci]: http://travis-ci.org
[coveralls-io]: http://coveralls.io
[cpputest]: https://cpputest.github.io/manual.html#getting_started
[travis-ci-custom]: https://docs.travis-ci.com/user/customizing-the-build
[cpp-option]: https://github.com/cwoodall/cpp-option
[gcc-4.8]: https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test
[wiki-gcov]: https://en.wikipedia.org/wiki/Gcov
[cpp-coveralls]: https://github.com/eddyxu/cpp-coveralls
[gcov-tmpl]: http://stackoverflow.com/questions/9666800/getting-useful-gcov-results-for-header-only-libraries
[template-project]: tbd
