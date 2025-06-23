# Simulation options
Models in GreenLight are represented as [ordinary differential equations (ODEs) - initial value problems](https://pythonnumericalmethods.studentorg.berkeley.edu/notebooks/chapter22.00-ODE-Initial-Value-Problems.html).
Simulations are therefore performed by ODE solvers, which inherently require choices regarding the simulation settings and algorithm.
The `options` attribute of a GreenLight object ([which can be set with an options node in the model definition](model_format.md#simulation-settings)) influences which method is used for solving the problem, which numerical algorithm is used, and various settings and parameters related to the algorithm.

In this file:
- [Modifying the simulation options](#modifying-the-simulation-options)
- [Options for GreenLight objects](#options-for-greenlight-objects)
  - [options\["t\_start"\] and options\["t\_end"\]](#optionst_start-and-optionst_end)
  - [options\["expand\_variables"\]](#optionsexpand_variables)
  - [options\["expand\_functions"\]](#optionsexpand_functions)
  - [options\["solving\_method"\]](#optionssolving_method)
    - ["solve\_ivp"](#solve_ivp)
    - ["solve\_ivp\_from\_str"](#solve_ivp_from_str)
  - [options\["interpolation"\]](#optionsinterpolation)
  - [options\["solver"\]](#optionssolver)
  - [options\["first\_step"\], options\["max\_step"\], options\["atol"\], \`options\["rtol"\]](#optionsfirst_step-optionsmax_step-optionsatol-optionsrtol)
  - [options\["output\_step"\]](#optionsoutput_step)
  - [options\["t\_eval"\]](#optionst_eval)
  - [options\["clip\_large\_nums"\]](#optionsclip_large_nums)
  - [options\["nans\_to\_zeros"\]](#optionsnans_to_zeros)
  - [options\["warn\_loading"\]](#optionswarn_loading)
  - [options\["warn\_runtime"\]](#optionswarn_runtime)
  - [options\["log\_runtime\_warnings"\]](#optionslog_runtime_warnings)
- [Supported combinations](#supported-combinations)


**NOTE:** experimenting with the simulation settings will quickly show that **these settings will surely influence the resulting output**. For example, choosing too low tolerances will cause the numerical approximation to be too rough, introducing large numerical errors to the results. It is therefore crucial to test model settings and find values that create a decent balance between running time, smoothness, and accuracy.

## Modifying the simulation options
See [simulation settings](model_format.md#simulation-settings) in [model format](model_format.md).
For a simple example showing how to modify options directly in the input argument, see [modifying and combining models](modifying_and_combining_models.md#combining-all-of-the-above).

## Options for GreenLight objects
GreenLight objects have an `options` attribute, which is represented by a `dict`. In order to remain consistent with [how models are defined in GreenLight](model_format.md), the `dict`'s keys and values are all strings. The following keys are used by GreenLight:

### options["t_start"] and options["t_end"]
These indicate the time span to consider when solving the ODEs. For example, an input data file may contain data with time stamps (in seconds) from 0 to 31536000 (the number of seconds in a year). `t_start` and `t_end` can control which part of this input data to consider. In particular, the difference between `t_end` and `t_start` will be the length of the simulated period.

**Default values:** `"t_start": "0", "t_end": "86400"` (one day, starting at the beginning of the input data).


###options["formatting_mode"]
Influences how the model, typically read from JSON files, is formatted when it is loaded onto a GreenLight object. The following values can be used:
- `numpy`: `numpy` mathematical expressions will be formatted in the GreenLight object with a `np` prefix. For example, `exp(x)` will be formatted as `np.exp(x)`. The [numpy](https://numpy.org/) package will be used for interpreting mathematical expressions.
- `math`: `math` mathematical expressions will be formatted in the GreenLight object with a `math` prefix. For example, `exp(x)` will be formatted as `math.exp(x)`. The [math](https://docs.python.org/3/library/math.html) package will be used for interpreting mathematical expressions.
- `numexpr`: mathematical expressions will not be formatted. The [numexpr](https://github.com/pydata/numexpr) package will be used for interpreting mathematical expressions.

See [mathematical expressions](math_expressions.md) for more information.

**Default value:** `"numpy"`

### options["expand_variables"]
If `"True"`, the mathematical expressions describing model variables will be expanded to be described using only built-in expressions, inputs, and the model states.

For example, consider a model with a state `y` and auxiliary states which depend on other expressions:
- `a1 = exp(a3)`
- `a2 = -y`
- `a3 = 2*y`
- `y = a1 + a2`

If `"expand_variables"` is `"True"`, then the expressions will be reformatted as follows:
- `a1 = exp(2*y)`
- `a2 = -y`
- `a3 = 2*y`
- `y = exp(a3) - y`

Expanding the variables can improve running speeds for some models. It allows the solving algorithm to consider only the states, without having to first compute auxiliary states.
At the same time, it seems that with very complex models, the expanded expressions for the states become too long to handle, which in turn slows down computation time, or breaks down computation completely.

**Default value:** `"False"`

### options["expand_functions"]
This option is similar to `"expand_variables"`, but is related to model functions instead.
Recall that [model-defined functions](model_format.md#model-defined-functions) are mathematical expressions defined in the model that may be used repeatedly.
For example, consider a model with the following:
- A model function `"func1(a,b) = a + b**2"`
- A variable `y = func1(v1, v2+v3) + v4`

If `"expand_functions"` is `"True"`, then the expression for `y` will be reformatted as:
- `y = ((v1) + (v2+v3)**2) + v4`

The advantage of expanding functions is that these then do not need to be defined or interpreted during solving. This helps make the solving algorithm much simpler.

**Default value:** `"True"`

### options["solving_method"]
This option determines which method of `greenlight._solve` is used for solving the model. Currently, 2 methods are implemented:

#### "solve_ivp"
This method uses [scipy.integrate.solve_ivp](https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_ivp.html)
in a rather straightforward way. No considerable efforts have been made here to improve performance. See [greenlight/_solve/_solve_ivp.py](../greenlight/_solve/_solve_ivp.py)

#### "solve_ivp_from_str"
This method also uses [scipy.integrate.solve_ivp](https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_ivp.html), however, it uses a reformatting of the entire model as a string,
which is then used to define a Python function which can be sent directly to `scipy.integrate.solve_ivp`.
From an algorithmic viewpoint, this method should generate the same output as the method `"solve_ivp"`, but it seems to improve running time considerably.
See [greenlight/_solve/_solve_ivp_from_str.py](../greenlight/_solve/_solve_ivp_from_str.py)

**Default value:** `"solve_ivp_from_str"`

### options["interpolation"]
This option controls how input and output data is interpolated, both when reading data from files and when creating the model output.
If `options["interpolation"]` is `"linear"`, then linear interpolation is used.
Otherwise, "left" interpolation is used, i.e., when reading or writing data for value $t$, the closest value to $t$, but always smaller than it ("to the left") is used.
"Left" interpolation may in some cases provide faster running times than "linear".

Note that in all cases, if interpolation is required outside the boundaries of the data
(for example, reading input data at time t=100 but data is only available up to time 90),
then the nearest values are used, i.e., the beginning or the end of the data.

**Default value:** `"linear"`

### options["solver"]
This option determines the `method` argument given as the ODE solver's options.
See the [documentation of scipy.integrate.solve_ivp](https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_ivp.html)
for the available solvers for `solve_ivp` and `solve_ivp_from_str`, and the difference between them.

**Default value:** `"BDF"`


### options["first_step"], options["max_step"], options["atol"], `options["rtol"]
These are standard options arguments for ODE solvers.
See the [documentation of scipy.integrate.solve_ivp](https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_ivp.html) for more information.

**Default values:** `"first_step": "None", "max_step": "3600",  "atol": "1e-3", "rtol": "1e-6"`

### options["output_step"]
This value controls the step size of the output generated after the simulation is run. It may also control the time points at which the ODE is evaluated, see next paragraph.

**Default value:** `"3600"` (one hour)

### options["t_eval"]
This value controls the argument `t_eval` that is passed to the ODE solver, see [scipy.integrate.solve_ivp](https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_ivp.html).
However, this attribute does not work in the same way as `t_eval` in `solve_ivp`:

If `options["t_eval"]` is `"None"`, then `None` is passed to the ODE solver as `t_eval`.<br>
Otherwise, the values passed to the solver as `t_eval` are the time points from `options[t_start]` to `options[t_end]`, with `options[output_step]` step size in between.

**Default value:** `"None"`

### options["clip_large_nums"]
If this value is `"True"`, the solver will replace very large and very small numbers during the solving process:
numbers greater than `10**38` (roughly [the limit of a 32-bit floating point](https://en.wikipedia.org/wiki/Single-precision_floating-point_format))
will be replaced by `10**38`, and numbers smaller than `-10**38` will be replaced by `-10**38`.

This allows to avoid some numerical errors during solving, although of course it may influence the accuracy of the solution.

**Default value:** `"True"`

### options["nans_to_zeros"]
If this value is `"True"`, the solver will replace any NaN value it encounters by 0. This allows to avoid some numerical errors during solving, although of course it may influence the accuracy of the solution.

**Default value:** `"True"`

### options["warn_loading"]
If this value is `"True"`, the solver will issue warnings to the Python console about events happening during model loading. This includes when a variable definition, unit, description, or reference is overwritten. This often happens when a model is composed of multiple files or when an input prompt changes model settings, see [Combining and modifying models](modifying_and_combining_models.md).

When this value is `"False"`, warnings will not be issued during loading but they will be added to the simulation log.

**Default value:** `"False"`

### options["warn_runtime"]
If this value is `"True"`, the solver will issue warnings to the Python console about warnings caught during model solving. This typically includes numerical issues encountered by the solver. It is good to be aware that ODE solvers may issue multiple warnings about numerical problems encountered during solving, yet, this doesn't mean that the solving failed. A runtime warning typically just means the simulation result should be checked, and possibly some numerical settings may need to be adjusted.

Note, however, that some warnings issued by the solver may not be caught, which means they will be issued even if this value is `"False"`. Also, some solving methods may fail to issue warnings for certain runtime events, see their separate documentation for more information.

When this value is `"False"`, warnings that are caught during runtime will not be issued during runtime. These warnings will still be included in the simulation log (but see next paragraph). Warnings that are not caught will be issued to the Python console, and will not be included in the simulation log.

**Default value:** `"False"`

### options["log_runtime_warnings"]
If this value is `"True"`, the simulation log file will include all warnings that were caught during runtime. However, sometimes this creates exceptionally long log files, which users may prefer to avoid. If this value is `"False"`, runtime warnings will not be included in the simulation log.

**Default value:** `"True"`


## Supported combinations
Depending on the `solving_method` chosen, not all solving options have been implemented.
The following table summarizes the currently supported options combinations:

| `solving_method`     | `solver`                                             | `formatting_mode` | `expand_variables`, `expand_functions`                                       |
|----------------------|------------------------------------------------------|-------------------|------------------------------------------------------------------------------|
| `solve_ivp`          | `RK45`, `RK23`, `DOP853`, `Radau`, `BDF`, or `LSODA` | `numpy`           | If `expand_variables` is `"True"`, `expand_functions` must also be `"True"`  |
|                      |                                                      | `math`            | `expand_variables` must be `"False"`                                         |
|                      |                                                      | `numexpr`         | `expand_functions` must be `"True"`                                          |
| `solve_ivp_from_str` | `RK45`, `RK23`, `DOP853`, `Radau`, `BDF`, or `LSODA` | `numpy`           | `expand_variables` must be `"False"` and `expand_functions` must be `"True"` |
|                      |                                                      | `math`            | Not supported                                                                |
|                      |                                                      | `numexpr`         | Not supported                                                                |

