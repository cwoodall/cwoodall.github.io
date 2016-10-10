---
layout: post
author: Chris Woodall
title: "You Might Want To Sit Down: How Sarcastic Documentation Can Be Negative"
date: 2016-10-08 16:00
comments: true
categories: blog
---

``` c++
from z3 import *
f_in = Int('f_in')
f_out = Int('f_out')
d, m = Int('d m')
facts = [f_out == (f_in / d) * m, f_in / d >= 2e6, f_in / d <= 4e6, f_in == 24e6, d != 0, f_out == 120e6]
solve(*facts)
```
