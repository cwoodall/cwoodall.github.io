``` c++
from z3 import *
f_in = Int('f_in')
f_out = Int('f_out')
d, m = Int('d m')
facts = [f_out == (f_in / d) * m, f_in / d >= 2e6, f_in / d <= 4e6, f_in == 24e6, d != 0, f_out == 120e6]
solve(*facts)
```
