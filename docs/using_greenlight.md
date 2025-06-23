# Using GreenLight

GreenLight can be run using the `main` function (see [I just want to run a greenhouse simulation](../README.md#i-just-want-to-run-a-greenhouse-simulation))
but for more elaborate contexts it is probably best to use scripts in order to run simulations.
This file contains some information on how to run GreenLight in a Python script.

In this file:
- [Initializing GreenLight](#initializing-greenlight)
  - [Example - initialization](#example---initialization)
- [Running the model](#running-the-model)
  - [Example - running](#example---running)
  - [Example - output](#example---output)
- [Using the model output](#using-the-model-output)
  - [Example - viewing the model output](#example---viewing-the-model-output)
- [More examples](#more-examples)


## Initializing GreenLight
The [GreenLight constructor](../greenlight/core.py) takes 3 arguments, which all take the empty string `""` as default:

- `base_path`
- `input_prompt`
- `output_path`

`base_path` is a location on the local machine which serves as a basis for where other files are searched for.
This is meant to be a full path on your local machine. Since this contains private information (the way files are organized on your computer),
this value is not included in the logs and outputs created by GreenLight.

`input_prompt` is a string, dict, or a list of strings and dicts. In its simplest form, it is just the location (relative) to `base_path`
of a model definition file, written according to the [GreenLight model format](model_format.md).
However, multiple definitions can be combined, see [Modifying and combining files](modifying_and_combining_models.md#input-argument-format).

`output_path` is a location (relative to `base_path`) of where the model output data (in CSV format) should be saved.
If you don't want to save output data, simply leave this as `""`. In addition to the output data, GreenLight will also create
a simulation log (detailing model modifications and numerical issues encountered during solving), and a log of the model format used.

### Example - initialization

A simple example of how GreenLight may be run is:
```python
from greenlight import GreenLight
mdl = GreenLight(base_path="C:\\models",
                 input_prompt="my_model.json",
                 output_path="output.csv")
```

In this case, it is assumed that `C:\models\my_model.json` contains a [model definition in the GreenLight format](model_format.md).
The path `C:\models\output.csv` will be set as the location for the output data file.

## Running the model
Running a model in GreenLight is done in three steps:
- Loading: model definitions are loaded, based on the `input_prompt`, into a GreenLight object.
- Solving: the [ODEs](https://en.wikipedia.org/wiki/Ordinary_differential_equation)
defining a model are [solved](https://pythonnumericalmethods.studentorg.berkeley.edu/notebooks/chapter22.00-ODE-Initial-Value-Problems.html).
- Saving: the results are saved to file.

### Example - running
The above sequence can be done in the following way (following the previous example):
```python
mdl.load()
mdl.solve()
mdl.save()
```
These three commands can also be executed by running:
```python
mdl.run()
```

The details of what is done during loading, solving, and saving depends on the
[input prompt](modifying_and_combining_models.md#combining-all-of-the-above)
and the [simulation options](simulation_options.md).
In the saving phase, besides the model output data, also a simulation log and a model structure log are created.

### Example - output
In the case described in the current example, with `base_path="C:\\models"`
and `output_path="output.csv"`, the following files will be generated:
- `C:\models\output.csv` - the simulated output data
- `C:\models\output_model_struct_log.json` - a log of the model structure used in the simulation
- `C:\models\output_simulation_log.txt` - a log of the simulation, including overwriting during load, and numerical issues encountered while solving

## Using the model output
Model output is saved in a CSV file, in the following format:
1. The first row of the output file contains the variable names
2. The second row contains the variable descriptions
3. The third row contains the variable units
4. The next rows contain the time trajectory of the variables. The first column is the time column, and the next columns are the model variables

### Example - viewing the model output
With this output format in mind, the following example can be used to display the time trajectory of a variable:
```python
import pandas as pd
import matplotlib.pyplot as plt

"""Load simulation result"""
output_df = pd.read_csv("C:\\models\\output.csv", header=None)
variable_names = output_df.iloc[0]
descriptions = output_df.iloc[1]
units = output_df.iloc[2]

# Reformat the DataFrame with variable names as columns
output_df = output_df.iloc[3:].reset_index(drop=True).apply(pd.to_numeric)
output_df.columns = variable_names

# Create dictionaries for descriptions and units
descriptions_dict = dict(zip(variable_names, descriptions))
units_dict = dict(zip(variable_names, units))

"""Show the trajectory of variable my_variable"""
var = "my_variable"
output_df.plot(
    x="Time",
    y=var,
    xlabel="Time (s)",
    ylabel=f"{var} ({units_dict[var]})",
    title=descriptions_dict[var],
    legend=None,
)
plt.show()
```

**Note:** the examples above can be combined into one file which runs the model and analyzes the results.
However, this is often inconvenient, because model runs take quite some time. For practical purposes, it is better to split these scripts
into two files: one which runs the simulations, and another one which loads the simulation data, displays and analyzes it.

## More examples
The following examples are included in the GreenLight repository:
- `scripts/greenlight_example` simple example, available as a a [Python script](../scripts/greenlight_example.py) and a [Jupyter notebook](../notebooks/greenlight_example.ipynb)
- [`scripts/katzin_2020/`](../scripts/katzin_2020/Readme.txt) Rerun the simulations from [Katzin (2020)](https://doi.org/10.1016/j.biosystemseng.2020.03.010) and reproduce the results
- [`scripts/katzin_2021/`](../scripts/katzin_2021/Readme.txt) Rerun the simulations from [Katzin (2021a)](https://doi.org/10.1016/j.apenergy.2020.116019) and reproduce the results

