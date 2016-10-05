In a recent effort to post my [previous blog post][prev-post] on making an option type in
C++ ([github][cpp-option]) I decided to provide some unit testing, code coverage and continuous integration
support for that build.

- [travis support][travis-ci]
  - .travis.yml
    - Rather straight forward to get started
    - Womp defaults to ubuntu 12.04 which doesn't support C++11... We need to install our own gcc-4.8 to
    make this work. Luckily this is pretty straight forward thanks to this [ppa][gcc-4.8]

- [cpputest support][cpputest]
  - Why CPPUTEST instead of GTEST?
    1. Familiarity (for me)
    2. Embedded systems development and goals
  - custom build and install script
    - [custom scripts travis][travis-ci-custom]
    - see `get-cpputest.sh`
- Adding coveralls support
  - Add coveralls token as an environment value in travis
  - Get [gcov][wiki-gcov] working
    - excludes
    - proper compiler flags (makefile)
  - Use the [cpp-coveralls python library][cpp-coveralls]... And it magically works pretty well...
    - womp make sure to pass gcov-4.8

Pretty much done at this point. See a template project [here][template-project]

Resources:
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
