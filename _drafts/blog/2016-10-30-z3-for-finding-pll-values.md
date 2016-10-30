---
layout: post
author: Chris Woodall
title: "Overcomplicated Solutions To Engineering Problems: Using Z3 For Finding PLL Values for the Freescale K64F12 Microcontroller"
date: 2016-10-29 16:00
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

## CLI with click

## Creating The Web Interface with flask

## Conclusion

[ms-research]: link
[z3]: link
[github-page]: link
[demo]: link
[freescale]: link
[k64-family-page]: link
[pll-wiki]: link
[endless-turtles]: link
