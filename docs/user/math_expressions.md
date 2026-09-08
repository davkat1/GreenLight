# Mathematical expressions
In this file:
- [`math` expressions](#math-expressions)
- [`numexpr` expressions](#numexpr-expressions)
- [What happens with these expressions?](#what-happens-with-these-expressions)
  - [If options\["formatting\_mode"\] is "math"](#if-optionsformatting_mode-is-math)
  - [If options\["formatting\_mode"\] is "numpy"](#if-optionsformatting_mode-is-numpy)
  - [If options\["formatting\_mode"\] is "numexpr"](#if-optionsformatting_mode-is-numexpr)
- [max, min, and pi](#max-min-and-pi)
  - [max and min](#max-and-min)
  - [pi](#pi)


Model definitions that are formatted according to [GreeLight's model format](model_format.md) include mathematical
expressions that are described using strings. There is currently a limited set of mathematical expressions that are
recognized by GreenLight and can be processed by the various formatting modes. These are the following
(see [greenlight/_load/_parse_model.py](../greenlight/_load/_parse_model.py)):

## `math` expressions:
Expressions that are supported in Python's `math` library:
- `sin`
- `cos`
- `tan`
- `sinh`
- `cosh`
- `tanh`
- `log`
- `log10`
- `log1p`
- `exp`
- `expm1`
- `sqrt`
- `floor`
- `ceil`
- `inf`
- `radians`

## `numexpr` expressions:
Expressions that are supported by [NumExpr](https://github.com/pydata/numexpr):
- `where`
- `arcsin`
- `arccos`
- `arctan`
- `arctan2`
- `arcsinh`
- `arccosh`
- `arctanh`
- `conj`
- `real`
- `imag`
- `complex`
- `contains`
- `abs`
- `mod`
- `logical_and`
- `logical_or`

This means that the above expressions (both `math` and `numexpr` expressions) will not be treated by GreenLight as model functions or variables. For example,
if the expression `sqrt(var)` appears in a model definition, GreenLight will not require a definition of `sqrt`, it will rely instead on
`options["formatting_mode"]` (see [Simulation options](simulation_options.md)) to figure out how to interpret this expression.

## What happens with these expressions?
For all these expressions, GreenLight will not try to interpret them. Instead, it may reformat them. The reformatting will
depend on `options["formatting_mode"]` (see [Simulation options](simulation_options.md))

### If options["formatting_mode"] is "math"
All of the `math` expressions will be converted from `<exp>` to `math.<exp>`. The other expressions will not be modified.

### If options["formatting_mode"] is "numpy"
All of the above expressions (both `math` and `numpy`) will be converted from `<exp>` to `np.<exp>`.

### If options["formatting_mode"] is "numexpr"
The expressions will not be modified, since NumExpr can interpret them as they are.

## max, min, and pi
### max and min
`max` and `min` are very common functions but there is no common way to interpret them. Note for example that
```python
max(5,6)
```
works fine in Python but the following fails:
```python
import numpy as np
np.max(5,6)
```
Instead, the NumPy equivalent of `max(5,6)` is `np.maximum(5,6)`.

Due to this ambiguity, in GreenLight `max` and `min` are not builtin expressions. If you want to these expressions in
your model, you will have to define it yourself, for example (see [greenhouse_vanthoor_2011_chapter_8.json](../models/katzin_2021/definition/vanthoor_2011/greenhouse_vanthoor_2011_chapter_8.json)):
```yaml
"min(a,b)": {
    "type": "function",
    "definition": "(a<b)*a + (b<=a)*b",
    "description": "Minimum of two variables"
},
"max(a,b)": {
    "type": "function",
    "definition": "(a>b)*a + (b>=a)*b",
    "description": "Maximum of two variables"
}
```

### pi
`pi` is also a very common expression in Python but NumExpr does not know how to evaluate it. Therefore, in order
to allow consistent solving regardless of the method chosen, `pi` is not a builtin expression in GreenLight. You may define it yourself
(again, see [greenhouse_vanthoor_2011_chapter_8.json](../models/katzin_2021/definition/vanthoor_2011/greenhouse_vanthoor_2011_chapter_8.json)):
```yaml
"pi" : {
    "unit" : "",
    "type" : "const",
    "definition" : "3.141592653589793",
    "description" : "The constant pi"
}
```
