---
layout: post
author: Chris Woodall
title: "Using Z3 For Finding PLL Values for the Freescale K64F12 Microcontroller"
date: 2016-11-05 16:00
comments: true
categories: blog
---

A couple of months ago I had to deal with managing multiple embedded systems with
the same chip (the [Freescale][freescale] [Kinetis K64F12][k64-family-page] family),
but a variety of different input clock frequencies. The output clock frequencies
for these projects were all the same. To solve this problem, once you have the
proper clock mode configurations (a struggle in its own right), you need to
set the [phase-locked loop (PLL)][pll-wiki] parameters which are calculated using
the following equation: $$f_{out} = VDIV * \frac{f_{in}}{PDIV}$$ (eq. 1), where you need
to find values for _VDIV_ and _PDIV_ which solve the equation and also satisfy
a variety of constraints. The details of this equation and its related constraints
will be approached later. Once you know the equation and constraints it is easy to calculate the PLL parameters; however it can be a tedious little bit of math...
plus there can be multiple valid solutions. I wanted to automate this task so in
the future I could just adjust these values without having to dig out the datasheet
and do the math again.

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


```python
# To print out the results
model = solve(facts)
```

```
[d = 10, m = 48, f_out = 120000000, f_in = 25000000]
```

```python
# But the model returns none
print model
```

```
None
```

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
```

```python
print(model)
```

```
[d = 10, m = 48, f_out = 120000000, f_in = 25000000]
```

```python
print("Now we can play with the model: f_in == {}".format(model[params['f_in']]))
```

```
Now we can play with the model: f_in == 25000000
```

## Dressing Up The Solution

```
$ k64_pll_calculator --help
Usage: k64_pll_calculator [OPTIONS]

  Simple program which takes an input frequency and an output frequency and
  returns the pdiv and vdiv necissary for the pll in the freescale k64
  processors

Options:
  -i, --freq_in FLOAT   Input frequency value in Hz
  -o, --freq_out FLOAT  Output frequency value in Hz
  -v, --verbosity       Verbosity of output
  --version             Show the version and exit.
  --help                Show this message and exit.
```

```
$ k64_pll_calculator -i 25e6 -o 120e6
[d = 10, m = 48, f_out = 120000000, f_in = 25000000]
```

```
$ k64_pll_calculator -i 1e6 -o 120e6
No results found.
```

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

```
$ curl "http://k64-pll-calculator.herokuapp.com/solve?fin=1e6&fout=80e6"
{
  "payload": {
    "error": "model is not available"
  },
  "status": "error"
}
```

![](/assets/img/posts/k64-pll-calculator-web-example.gif)

## Conclusion

[ms-research]: link
[z3]: link
[github-page]: link
[demo]: link
[freescale]: link
[k64-family-page]: link
[pll-wiki]: link
[endless-turtles]: link
