# Using GreenLight

GreenLight can be run using the `main` function (see [I just want to run a greenhouse simulation](../README.md#i-just-want-to-run-a-greenhouse-simulation))
but for more elaborate contexts it is probably best to modify model component and to use scripts in order to run simulations.
This file contains some more information.

In this file:
- [Initializing GreenLight using built-in models](#initializing-greenlight-using-built-in-models)
  - [Initializing with default values](#initializing-with-default-values)
  - [Initializing the default model with input weather data and custom season length](#initializing-the-default-model-with-input-weather-data-and-custom-season-length)
- [Copying the built-in model definition files to a local location](#copying-the-built-in-model-definition-files-to-a-local-location)
- [Initializing GreenLight with local files](#initializing-greenlight-with-local-files)
- [Running the model](#running-the-model)
  - [Example - running](#example---running)
  - [Example - output](#example---output)
- [Using the model output](#using-the-model-output)
  - [Example - viewing the model output](#example---viewing-the-model-output)
- [More examples](#more-examples)

## Initializing GreenLight using built-in models
The [GreenLight constructor](../greenlight/core.py) takes 4 optional arguments:

- `base_path`
- `input_prompt`
- `output_path`
- `optional_prompt`

### Initializing with default values
The simplest way to initialize a GreenLight object is with default values:

```python
from greenlight import GreenLight
mdl = GreenLight()
```

With these default values:
- `base_path` takes on the location where Python stores the models that are bundled with the `greenlight` package
- `input_prompt` sets the loaded model as the default GreenLight model
(the model of [Katzin 2021](https://doi.org/10.1016/j.apenergy.2020.116019)) and default weather data
(data from [Katzin 2025](https://doi.org/10.4121/78968E1B-EAEA-4F37-89F9-2B98BA3ED865.V2))
- `output_path` sets the generated output location as a folder "Output" placed in the current active folder
- `optional_prompt` is blank (`""`)

Running the model with the above settings will run one day of a greenhouse simulation with weather values from
Bleiswijk, the Netherlands on 20/10/2009, and will place the output in an "output" folder, under the current active folder.

### Initializing the default model with input weather data and custom season length
The default settings will not generate very informative input, since the simulation is limited to 1 day
and the weather data is quite limited.

By default, GreenLight uses data from
[Katzin et al. (2025). Data from: ‘GreenLight - An open source model for greenhouses with supplemental lighting:
Evaluation of heat requirements under LED and HPS lamps’ 4TU.ResearchData.](https://doi.org/10.4121/78968E1B-EAEA-4F37-89F9-2B98BA3ED865.V2)
The dataset contains weather recorded in Bleiswijk, the Netherlands between 20 October 2009 and 7 February 2010.

In order to run a longer simulation (note that the provided dataset contains only 111 days),
the following can be used:

```python
from greenlight import GreenLight

# Numbers of days to simulate
n_days = 10

# Include the simulation length (in seconds) in the model options
options = { "options": { "t_end": str(n_days * 24 * 3600) } }

# Define the model with the test data and the new options
mdl = GreenLight(optional_prompt=options)
```

In the above, `input_prompt` takes the default value, so GreenLight uses the default greenhouse model and weather data.
But since `optional_prompt` modifies the `"t_end"` option, the simulation is longer.

Most users will usually prefer to use a dataset that is relevant for their needs. For this, see
[Acquiring input data for running scripts](input_data.md#acquiring-input-data-for-running-scripts).
For example, if the data is acquired, formatted, and placed under the current active directory, in a subdirectory called
`C:\input_data\weather_ams_katzin_2021_from_sep_27_000000.csv`, it can be loaded onto the model like this:
```python
from greenlight import GreenLight

# Numbers of days to simulate
n_days = 10

# Include the simulation length (in seconds) in the model options
options = { "options": { "t_end": str(n_days * 24 * 3600) } }

# The location of the formatted data
weather_data = r"C:\input_data\weather_ams_katzin_2021_from_sep_27_000000.csv"

# Define the model with the test data and the new options
mdl = GreenLight(optional_prompt=[options, weather_data])
```

## Copying the built-in model definition files to a local location
The above is sufficient for simple cases where the user doesn't need to delve to deep into the model structure,
parameters, or other settings. However, in many cases there is a need to modify or extend the model.
In this case, it is best to copy all the model settings files into a local, user-chosen location,
where they can be modified or extended.

For this, the function [`copy_builtin_models`](../greenlight/utils.py) can be used. This function takes a single argument,
a string pointing to a location where the built-in models should be copied to. For example:
```python
import greenlight
greenlight.copy_builtin_models(r"C:\builtin_models")
```
The above will copy all the built-in models that are packaged with `greenlight` into the folder `C:\builtin_models\models`.
From here, users can modify the models in their local copies without worrying about modifying the original model files.

## Initializing GreenLight with local files
Once the built-in models are copied to a local location, GreenLight can be initialized with custom settings.
As stated above, the [GreenLight constructor](../greenlight/core.py) takes 4 arguments:
- `base_path`
- `input_prompt`
- `output_path`
- `optional_prompt`

`base_path` is a location on the local machine which serves as a basis for where other files are searched for.
This is meant to be a full path on your local machine. Since this contains private information (the way files are organized on your computer),
this value is not included in the logs and outputs created by GreenLight.

`input_prompt` is a string, dict, or a list of strings and dicts. In its simplest form, it is just the location (relative to `base_path`)
of a model definition file, written according to the [GreenLight model format](model_format.md).
However, multiple definitions can be combined, see [Modifying and combining files](modifying_and_combining_models.md#input-argument-format).

`output_path` is a location (relative to `base_path`) of where the model output data (in CSV format) should be saved.
If you don't want to save output data, simply leave this as `""`. In addition to the output data, GreenLight will also create
a simulation log (detailing model modifications and numerical issues encountered during solving), and a log of the model format used.

`optional_prompt` can be used to add more prompts to `input_prompt`. It is mostly used as above, where `input_prompt`
defaults to the default model definition file, but `optional_prompt` allows making more modifications.

A simple example of how GreenLight may be run is:
```python
import greenlight
greenlight.copy_builtin_models(r"C:\builtin_models")
mdl = greenlight.GreenLight(
        base_path=r"C:\builtin_models\models",  # Location of copied built-in models
        input_prompt=r"katzin_2021\definition\main_katzin_2021.json",  # Location (relative to base_path) of file defining the Katzin 2021 greenhouse model
        output_path="output\katzin_2021_output.csv")  # Location (relative to base_path) of where output should be saved
```

Of course, other models besides the copied built-in models can be used. The important thing is that `input_prompt`
points to a file which provides a [model definition in the GreenLight format](model_format.md).


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
In the case described in the previous example, with `base_path=r"C:\builtin_models\models"`
and `output_path="katzin_2021_output.csv"`, the following files will be generated:
- `C:\builtin_models\models\output\katzin_2021_output.csv` - the simulated output data
- `C:\builtin_models\models\output\katzin_2021_output_model_struct_log.json` - a log of the model structure used in the simulation
- `C:\builtin_models\models\output\katzin_2021_output_simulation_log.txt` - a log of the simulation, including overwriting during load, and numerical issues encountered while solving

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
output_df = pd.read_csv(r"C:\builtin_models\models\output\katzin_2021_output.csv", header=None)
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
