---
layout: post
author: Chris Woodall
title: "Using Z3 to Find Clock Configurations Values for ARM Cortex Microcontrollers"
date: 2016-11-06 16:00
comments: true
categories: blog
---

A few weeks ago I was setting up multiple embedded systems using the [NXP][nxp]
[Kinetis K64F12][k64-family-page] family of microcontrollers. Do to an oversight
a few of the different systems had different input clock frequencies, but all
were intended to work at the same output clock frequency. This is not a major
issue and the ARM Cortex-M4 processors are designed to solve this issue using
a [phase-locked loop (PLL)][pll-wiki]. A PLL can take a clock, of one frequency
and output a rather clean clock of another frequency; however, it must be properly
configured. My problem now was a configuration, and mathematics problem. The
parameters are calculated using the following equation:

$$f_{out} = VDIV * \frac{f_{in}}{PRDIV}$$, where $$VDIV$$ and $$PRDIV$$ are the parameters needed for the configuration. and $$f_{in}$$ and $$f_{out}$$ are your input and output frequency which you know ahead of time.


A solution to this equation is straightforward but requires a little bit of guessing,
and also checking your answers against a series of constraints specified in the
[datasheet][datasheet]. The details of this equation and its related constraints
will be approached later. I wanted to automate this task so in
the future I could just adjust these values without having to dig out the [datasheet][datasheet]
and do the math again. Also to possibly automate making the clock configuration code
to prevent me from being the only person who understood how to configure the clocks.

What is someone who loves automation to do? Well, you could solve the equation
directly. However, [Michael Abed][endless-turtles] introduced me to a program and
library called [Z3][z3] which is a constraints solver from
[Microsoft Research][ms-research] which I found interesting and wanted to do a
simple project with since I thought it might be useful in the future. Also, this
problem is well-suited as it can take a series of equations and constraints and
search the solution space rather trivially easily. Also, it has a way of deciding
if no solution is possible. So I decided
to use the [Z3][z3] python bindings to create a python library, with a command line
tool and a web API for solving this problem. This is most certainly overkill, but
considering how easily it all went together I would do it again to solve similar
problems.

You can see the code on [GitHub][github-page] and also play with see the resulting
[website and API demo][demo]. But read on for more details!

<!-- more -->

## Constraining The Problem

Z3 is a constraint solver, so the constraints needs to be specified in a way that Z3 can understand and used. For those who want to follow along at home I created an [ipython notebook][ipynb]. To get started with it you will need to install the [Z3][z3] python package:

```
$ sudo pip install z3-solver
```

The first step is to specify the parameters we will be dealing with. Looking at the equation above and the [datasheet][datasheet] the parameters can be determined to be `f_in`, `f_out`, `d` ($$PRDIV$$) and `m` ($$VDIV$$) which can all be constrained to the set of Integers. The `z3.Int()` type will handle this.

```python
from z3 import *

# Lets create a dictionary of all of our parameters.
# Where:
#    - f_in: Input Frequency
#    - f_out: Output Frequency
#    - d: PRDIV from datasheet. This is the division term
#    - m: VDIV from datasheet. This is the multiply term
params = {k: Int(k) for k in ['f_in', 'f_out', 'd', 'm']}
```

Now that the model parameters have been determined and appropriately constrained
to the Integer space, the remaining constraints need to be set. To do this an
array of "facts" will be created which will tell Z3 about our solution space.
This will include our equation for `f_out` in terms of `f_in`, `d` and `m`, but
there are also other constraints to make the values valid. These are found in the
[datasheet][datasheet] for the K64F12 family on pages 589 and 590, and come in the
form of ranges for `d` and `m`. The most important performance based constraint is
formed around `f_in / d` which determines the frequency of the input to the phase-locked
loops (PLL) multiplier stage. The facts are easy to write now. It is important to note
that the parameters are used to specify the constraints:

```python
# Lets look at the datasheet and define some constraints on value ranges
# The range tuples are in the format (lower_bound, upper_bound)
divide_range = (2e6, 4e6) # From K64F12 datasheet page 589
d_range = (1, 25)         # From K64F12 datasheet page 589
m_range = (24, 55)        # From K64F12 datasheet page 590

# Get the input and output frequency as user inputs.
# This is a quick and dirty handling of the inputs.
freq_in = 25e6
freq_out = 120e6

# Now we can constrain the equation with the "facts" we know
facts = [
    # define
    params['f_in'] == freq_in,
    params['f_out'] == freq_out,

    # Setup the equation which uses PRDIV (d) and VDIV (m)
    # This equation is set up from the K64 datasheet
    params['f_out'] == (params['f_in'] / params['d']) * params['m'],

    # From K64 datasheet page 589
    params['f_in'] / params['d'] >= divide_range[0],
    params['f_in'] / params['d'] <= divide_range[1],

    # From K64 datasheet page 589
    params['d'] >= d_range[0],  
    params['d'] <= d_range[1],

    # From K64 datasheet page 590
    params['m'] >= m_range[0],  
    params['m'] <= m_range[1]]
```

Now the `z3.solve()` function can be used to solve the model:

```python
# To print out the results
model = solve(facts)
```

Which results in:

```
[d = 10, m = 48, f_out = 120000000, f_in = 25000000]
```

Now it would be great to be able to take the newly found model parameter values and use them.
So let's print out the model directly to see what we have:

```python
# But the model returns none
print model
```

Yielding a resounding:

```
None
```

Oh no... It turns out that convenient `solve()` function does not return the model,
it just prints out the results to _STDIO_. To me this was not obvious at all.
What do we do instead? We use the [Z3][z3] [`Solver` class][z3-solver-class],
which is much more versatile. However, for this particular case I wrote a
function `solve_return_model()`, which acts like the `solve()` function but
returns the solved model instead of printing it, or an `Z3Exception` if there is
no constrained solution:

```python
#This method is defined in k64_pll_calculator/util.py
def solve_return_model(fact_list):
    """
    The default z3.solve() method prints to the screen. This uses the basis of
    that function to take a list of facts, add it to a solver and then return
    a z3 model with a solution.

    Relies on exceptions raised by calling s.mode() on an invalid model.

    @param a list of z3 facts and constraints
    @return A valid z3 model
    @raises Z3Exception
    """
    s = Solver()
    s.add(*fact_list)
    r = s.check()
    if r == unsat:
        print("no solution")
    elif r == unknown:
        print("failed to solve")

    return s.model()

model = solve_return_model(facts)

print(model)
```

So now we can print the model out:

```
[d = 10, m = 48, f_out = 120000000, f_in = 25000000]
```

And we can access our individual parameters:

```python
print("Now we can play with the model: f_in == {}".format(model[params['f_in']]))
```

Outputting:

```
Now we can play with the model: f_in == 25000000
```

Once a solution for $$PRDIV$$ and $$VDIV$$ has been found those values can be reported
and modified as needed. In this particular case they still need to be modified
to be in the actually bit-wise representation from the [datasheet][datasheet] (p 589).
One idea I had was to feed these values into a clock configuration struct so I could
generate my clock configuration header files directly.

## Dressing Up The Solution

Once I finished learning about [Z3][z3] I decided to wrap the results up into two
applications. The first was a CLI application which uses a library called
[click][click] which is a:

> Python package for creating beautiful command line interfaces in a composable way with as little code as necessary.

Usage is simple:

```
$ k64_pll_calculator --help
Usage: k64_pll_calculator [OPTIONS]

  Simple program which takes an input frequency and an output frequency and
  returns the PRDIV and vdiv necessary for the pll in the freescale k64
  processors

Options:
  -i, --freq_in FLOAT   Input frequency value in Hz
  -o, --freq_out FLOAT  Output frequency value in Hz
  -v, --verbosity       Verbosity of output
  --version             Show the version and exit.
  --help                Show this message and exit.

$ k64_pll_calculator -i 25e6 -o 120e6
[d = 10, m = 48, f_out = 120000000, f_in = 25000000]

$ k64_pll_calculator -i 1e6 -o 120e6
No results found.
```

And more importantly it was very easy to throw together. I have found
[click][click] to be very easy to use and have been using it for more complicated
command line applications.

The other interface I made was for the [web demo][demo] which uses [flask][flask]
to create an API endpoint at `/solve`. I then used [heroku](http://heroku.com) to
host it and a little bit of old school [jQuery](https://jquery.com) to make the
form asynchronous. You can use the end point with HTTP `GET` requests and query
strings as follows, returning JSON:

```
$ curl "http://k64-pll-calculator.herokuapp.com/solve?fin=20e6&fout=80e6"
{
  "payload": {
    "d": "8",
    "f_in": "20000000",
    "f_out": "80000000",
    "m": "32"
  },
  "status": "success"
}
```

In the case where the model has no solution:

```
$ curl "http://k64-pll-calculator.herokuapp.com/solve?fin=1e6&fout=80e6"
{
  "payload": {
    "error": "model is not available"
  },
  "status": "error"
}
```

And here is a little _.gif_ example of the [demo][demo] in action.

[![K64 PLL Calculator Demo](/assets/img/posts/k64-pll-calculator-web-example.gif)][demo]

## Conclusion

This was a fun distraction of a project. I got acquainted with a powerful tool
[Z3][z3] and also spent some time with python unit testing, [click][click], [flask][flask]
and dusting off some of my JavaScript skills (which made me want to update my
skill set in that region). I am mostly excited about future applications of [Z3][z3]
to my work, as it seems that many embedded systems problems and configuration problems
follow a similar template, which is they are constraint solving problems. This particular
problem was easy enough to do by hand, but I can think of many other cases where using
Z3 to solve a problem off-target, and putting the final model parameters onto the
embedded system could yield a high performance, low footprint solution.

Go forth and constrain your problems!

Please checkout the code on [GitHub][github-page]!

[nxp]: http://nxp.com
[ms-research]: https://www.microsoft.com/en-us/research/
[z3]: https://github.com/Z3Prover/z3
[github-page]: https://github.com/cwoodall/k64-pll-calculator
[demo]: http://k64-pll-calculator.herokuapp.com/
[k64-family-page]: https://cache.nxp.com/files/microcontrollers/doc/data_sheet/K64P144M120SF5.pdf
[datasheet]: http://cache.nxp.com/files/microcontrollers/doc/ref_manual/K64P144M120SF5RM.pdf
[pll-wiki]: https://en.wikipedia.org/wiki/Phase-locked_loop
[endless-turtles]: https://endless-turtles.com/
[ipynb]: https://github.com/cwoodall/k64-pll-calculator/blob/master/extras/notebook.ipynb
[z3-solver-class]: https://z3prover.github.io/api/html/classz3py_1_1_solver.html
[click]: http://click.pocoo.org/
[flask]: http://flask.pocoo.org/
