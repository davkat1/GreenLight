# Modifying and combining models
Files created according to GreenLight's [model format](model_format.md) can be modified, extended, or combined.

In this file:
- [Modifying and combining models using a processing\_order file](#modifying-and-combining-models-using-a-processing_order-file)
  - [processing\_order files](#processing_order-files)
- [Modifying and combining models using input arguments](#modifying-and-combining-models-using-input-arguments)
  - [Input argument format](#input-argument-format)
- [Modifying model variables with input data](#modifying-model-variables-with-input-data)
- [File location and path](#file-location-and-path)
- [Combining all of the above](#combining-all-of-the-above)


## Modifying and combining models using a processing_order file
When combining multiple files or definitions, it is essential to let GreenLight know about the order of precedence: for example,
if file `file1.json` defines the variable `var`, and file `file2.json` modifies the same variable, GreenLight needs to know which file to use.
For this, a `processing_order` file can be used to define the order of precedence.

### processing_order files
A `processing_order` files is a `JSON` file that has a node named `processing_order`. If such a node exists in a file, anything else in that file is ignored.
The node named `processing_order` is expected to contain **an array** (see for example, [json.org](https://www.json.org/json-en.html))

GreenLight will load each element in `processing_order`, where **a newer element overwrites previous elements**.
This means that precedence between elements goes from last to first: **every element takes priority over previous elements**. Example:

```yaml
"processing_order" : [
          "p1": {
            "type": "const",
            "definition": "5"
          },
          "p1": {
            "type": "const",
            "definition": "10"
          }
    ]
```

In this case, `p1` will receive the definition `"10"`.

The same logic can be used for combining files. Example:
```yaml
"processing_order" : [
      "model_def_file1.json",
      "model_def_file2.json"
    ]
```

In such a case, first the definitions in `model_def_file1.json` will be loaded, and afterwards the definitions in `model_def_file2.json`
will be loaded. If there is any variable that is defined both in `model_def_file1.json` and in `model_def_file2.json`, the definitions in
`model_def_file2.json` will overwrite the definitions in `model_def_file1.json`. GreenLight will log this overwriting in its log,
and, if `options["warn_loading"]` is `"True"` (see [Simulation options](simulation_options.md#optionswarn_loading)), a warning will be issued to the Python console.

**Note:** GreenLight allows and expects these kinds of duplicate definitions, because in this case it is clear which definition should take precedence.
However, GreenLight does not allow for the same variable to be defined twice in the same file (or the same input argument, see below),
since such double definitions create ambiguity, and they may happen unintentionally.

## Modifying and combining models using input arguments
GreenLight accepts an input prompt composed of Python strings, dicts, or lists containing them. In the case of lists,
GreenLight also uses the rule that **a newer element overwrites previous elements**, i.e., **every element takes priority over previous elements**.
Therefore, another way to ensure that `model_def_file2.json` extends (possibly overwriting some definitions) in `model_def_file1.json` is by using:
```python
from greenlight import GreenLight
mdl = GreenLight(base_path, ["model_def_file1.json", "model_def_file2.json"])
```

### Input argument format
Input arguments given can be one of the following:
- A string describing the location of a JSON or CSV file to be loaded onto the model:
```yaml
"model_def_file1.json"
```
- A string in JSON format describing a model component:
```yaml
' "p1": {
            "type": "const",
            "definition": "10"
          }
'
```

- A Python dict:
```yaml
{ "p1":
  {
  "type": "const",
  "definition": "10"
  }
}
```

## Modifying model variables with input data
Any model variable can be modified by providing a CSV file with data for that variable.
GreenLight will load this data onto the variable, and will not compute it as a model variable.
In order to do this, simply provide data for the variable as a model input,
see the section [inputs](model_format.md#inputs) in [model format](model_format.md)

## File location and path
There is a subtle difference between how GreenLight processes file locations,
depending on how they are provided.

- When file locations are provided **in an input argument**, it is assumed that
the GreenLight object already has a `base_path` defined, and that the user knows it.
Therefore, **file locations are read relative to the base_path**. What this means is that in the prompt:
```python
from greenlight import GreenLight
mdl = GreenLight(base_path, ["model_def_file1.json", "model_def_file2.json"])
```

GreenLight will search for the files `model_def_file1.json`, `model_def_file2.json` in the directory `base_path`.

- When file locations are provided **in a processing_order file**, one of two options are possible:
  - The full file path can be provided (not recommended, as this will easily break, for example when working on another computer).
  - The file location is given relative to the location of the `processing_order` file.

So if `main_model.json` looks like this:
```yaml
"processing_order" : [
      "model_def_file1.json",
      "model_def_file2.json"
    ]
```
Then GreenLight will expect `model_def_file1.json` and `model_def_file2.json` to be in the
same folder as `main_model.json`.

## Combining all of the above

Input arguments and `processing_order` files can be combined to make model modifications.
A typical use case is a `processing_order` file which combines several models into one model,
and modifications of input arguments to modify the file. For example:

File `main_model_file.json` may look like this:
```yaml
"processing_order" : [
      "model_def_file1.json",
      "model_def_file2.json"
    ]
```

and the call to GreenLight may be (see also [Simulation options](simulation_options.md)):

```python
from greenlight import GreenLight
mdl = GreenLight(base_path, ["main_model_file.json",
                  "input_data_file.csv",
                  {"options": {"t_start": "0", "t_end": "86400"}}])
```
