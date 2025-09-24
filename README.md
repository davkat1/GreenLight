# GreenLight
A Python platform for creating, modifying, and combining dynamic models, with a focus on horticultural greenhouses and crops.

## Quick start
```shell
pip install greenlight
python -m greenlight.main
```

or:
```shell
pip install greenlight
import greenlight
mdl = greenlight.GreenLight()
mdl.run()
```

## Announcements
### Change in default branch name
As of version `2.0.2`, the default branch name has changed from `master` to `main`.
If you have a local clone, you can update it by running the following commands:

```shell
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
```

### Previous versions
Versions 1.x of this repository are programmed in MATLAB, and their development is discontinued.
Looking for the last MATLAB version of GreenLight? You can find it [here](https://github.com/davkat1/GreenLight/tree/4ec6018e0aad2775ad11085d34f3886a7b7dd052).

### Active discussions on Discord
Users are welcome to join the [GreenLight Discord server](https://discord.gg/MwExawsgQc) to post their questions, wishes, ideas - and hopefully help each other.

## User's guide
GreenLight is a platform for creating, modifying, and combining dynamic models.
It was developed for simulating horticultural greenhouses and crops (and that still remains its main focus),
but its capabilities are more general. One strength of GreenLight is its use as a tool for **open science**,
as it allows for transparent, reusable, and shareable research in the domain of dynamic modelling.

Follow the instructions below based on what you want to do:
- [I just want to run a greenhouse simulation](#i-just-want-to-run-a-greenhouse-simulation)
- [I want to run a simulation for a specific location](#i-want-to-run-a-simulation-for-a-specific-location)
- [I want to modify a model setting, then view and analyze simulation results](#i-want-to-modify-a-model-setting-then-view-and-analyze-simulation-results)
- [I want to learn more about the definitions and architecture of GreenLight's greenhouse models](#i-want-to-learn-more-about-the-definitions-and-architecture-of-greenlights-greenhouse-models)
- [I want to learn more about the technical and numerical aspects of the GreenLight's models](#i-want-to-learn-more-about-the-technical-and-numerical-aspects-of-the-greenlights-models)
- [I want to extend, combine, implement a model from literature or develop my own model](#i-want-to-extend-combine-implement-a-model-from-literature-or-develop-my-own-model)
- [I want to further develop the GreenLight platform](#i-want-to-further-develop-the-greenlight-platform)


### I just want to run a greenhouse simulation
The simplest way to do this is to install greenlight through `pip` and then run `main`:
```shell
pip install greenlight
python -m greenlight.main
```
A dialog box will appear with various inputs, you can play around with those, hit **OK** and see what happens.

For more information about installation, see [installing GreenLight](docs/installation.md).

### I want to run a simulation for a specific location
Simulations performed as above will not be very informative unless specific weather data is provided as input.
Follow the instructions in [input data](docs/input_data.md) on how to acquire weather data which will allow you to perform simulations for specific locations.

### I want to modify a model setting, then view and analyze simulation results
Any complex modelling work will most likely require writing and using scripts or notebooks.
Have a look at [Using GreenLight](docs/using_greenlight.md) for a general explanation on how GreenLight can be used.
That page also contains [links to further examples](docs/using_greenlight.md#more-examples).

### I want to learn more about the definitions and architecture of GreenLight's greenhouse models
It is difficult to make modifications to the model without having a good understanding of the model structure and its various variables, constants, and inputs.
The only way to build a familiarity with the model is to carefully read through it. Fortunately, there is already quite some literature to help guide through the model.

The standard greenhouse model in GreenLight is based on [**Katzin (2021). Energy Saving by LED Lighting in Greenhouses: A Process-Based Modelling Approach**](https://doi.org/10.18174/544434).
This in turn is based on [**Vanthoor (2011). A model-based greenhouse design method**](https://edepot.wur.nl/170301).

The best way to get familiarized with the model is to read through these publications and understand what the variables represent.
A good way to start is with [Vanthoor's](https://edepot.wur.nl/170301) Chapter 8, which is represented in GreenLight in [greenhouse_vanthoor_2011_chapter_8.json](../models/katzin_2021/definition/vanthoor_2011/greenhouse_vanthoor_2011_chapter_8.json).
Try to read through this chapter together with the related JSON file to get a grasp of the model.

This can be continued by reading [Vanthoor's](https://edepot.wur.nl/170301) Chapter 9 with [crop_vanthoor_2011_chapter_9_simplified.json](../models/katzin_2021/definition/vanthoor_2011/crop_vanthoor_2011_chapter_9_simplified.json),
and reading [Katzin's](https://doi.org/10.18174/544434) Chapter 7 with [extension_greenhouse_katzin_2021_vanthoor_2011.json](../models/katzin_2021/definition/extension_greenhouse_katzin_2021_vanthoor_2011.json).
Only by reading through and understanding the different model components is it possible to make meaningful modifications.


### I want to learn more about the technical and numerical aspects of the GreenLight's models
Check [Simulation options](docs/simulation_options.md) about how various settings can be modified.

### I want to extend, combine, implement a model from literature or develop my own model
See [Model format](docs/model_format.md) and [Modifying and combining models](docs/modifying_and_combining_models.md).

### I want to further develop the GreenLight platform
At this point you may dig deeper into the code. Have a look at the [GreenLight package](greenlight/__init__.py) and explore the code and docstrings from there.

## Further documentation
See [Documentation](./docs/index.md).

## Notes
### License
This project is licensed under the [BSD 3-Clause-Clear License](https://choosealicense.com/licenses/bsd-3-clause-clear/). See the [LICENSE](LICENSE.txt) file for details.

### Repository structure
- `docs` contains detailed documentation on how to work with the repository
- `greenlight` holds the Python module containing the platform implementations
- `greenlight/models` contains files that define models implemented on the platform
- `notebooks` contain example notebooks that use the python module in this package
- `scripts` contains Python scripts and examples that use this package

### Contributors
- David Katzin, Wageningen University & Research, david.katzin@wur.nl
- Pierre-Olivier Schwarz, Université Laval
- Joshi Graf, Wageningen University & Research
- Stef Maree, Wageningen University & Research
- User [shanakaprageeth](https://github.com/shanakaprageeth) on [github.com](https://github.com)

### Acknowledgements
Thank you to [Ian McCracken](https://github.com/iancmcc) for providing the [PyPI GreenLight namespace](https://pypi.org/project/GreenLight/)


*This package was created with [Cookiecutter](https://github.com/audreyr/cookiecutter) and the [WUR Greenhouse Technology cookiecutter](https://git.wur.nl/glas/pyproject) project template.*
