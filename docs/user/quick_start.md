# Quick start

GreenLight is a platform for creating, modifying, and combining dynamic models.
It was developed for simulating horticultural greenhouses and crops (and that still remains its main focus),
but its capabilities are more general. One strength of GreenLight is its use as a tool for **open science**,
as it allows for transparent, reusable, and shareable research in the domain of dynamic modelling.

Follow the instructions below based on what you want to do:

(quick_start-sim_gh)=
## I just want to run a greenhouse simulation
The simplest way to do this is to install greenlight through `pip` and then run `main`:
```shell
pip install greenlight
python -m greenlight.main
```
A dialog box will appear with various inputs, you can play around with those, hit **OK** and see what happens.

For more information about installation, see [installing GreenLight](installation.md).

## I want to run a simulation for a specific location
Simulations performed as above will not be very informative unless specific weather data is provided as input.
Follow the instructions in [input data](input_data.md) on how to acquire weather data which will allow you to perform simulations for specific locations.

## I want to modify a model setting, then view and analyze simulation results
Any complex modelling work will most likely require writing and using scripts or notebooks.
Have a look at [Using GreenLight](using_greenlight.md) for a general explanation on how GreenLight can be used.
That page also contains {ref}`links to further examples <using_gl-more_examples>`.

## I want to learn more about the definitions and architecture of GreenLight's greenhouse models
It is difficult to make modifications to the model without having a good understanding of the model structure and its various variables, constants, and inputs.
The only way to build a familiarity with the model is to carefully read through it. Fortunately, there is already quite some literature to help guide through the model.

The standard greenhouse model in GreenLight is based on [**Katzin (2021). Energy Saving by LED Lighting in Greenhouses: A Process-Based Modelling Approach**](https://doi.org/10.18174/544434).
This in turn is based on [**Vanthoor (2011). A model-based greenhouse design method**](https://edepot.wur.nl/170301).

The best way to get familiarized with the model is to read through these publications and understand what the variables represent.
A good way to start is with [Vanthoor's](https://edepot.wur.nl/170301) Chapter 8, which is represented in GreenLight in [greenhouse_vanthoor_2011_chapter_8.json](https://github.com/davkat1/GreenLight/tree/main/greenlight/models/katzin_2021/definition/vanthoor_2011/greenhouse_vanthoor_2011_chapter_8.json).
Try to read through this chapter together with the related JSON file to get a grasp of the model.

This can be continued by reading [Vanthoor's](https://edepot.wur.nl/170301) Chapter 9 with [crop_vanthoor_2011_chapter_9_simplified.json](https://github.com/davkat1/GreenLight/tree/main/greenlight/models/katzin_2021/definition/vanthoor_2011/crop_vanthoor_2011_chapter_9_simplified.json),
and reading [Katzin's](https://doi.org/10.18174/544434) Chapter 7 with [extension_greenhouse_katzin_2021_vanthoor_2011.json](https://github.com/davkat1/GreenLight/tree/main/greenlight/models/katzin_2021/definition/extension_greenhouse_katzin_2021_vanthoor_2011.json).
Only by reading through and understanding the different model components is it possible to make meaningful modifications.

## I want to learn more about the technical and numerical aspects of the GreenLight's models
Check [Simulation options](simulation_options.md) about how various settings can be modified.

## I want to extend, combine, implement a model from literature or develop my own model
See [Model format](model_format.md) and [Modifying and combining models](modifying_and_combining_models.md).

## I want to further develop the GreenLight platform
At this point you may dig deeper into the code. Have a look at the documentation for the [Open API](../api/greenlight.rst) and [For developers](/developer/greenlight.rst)
