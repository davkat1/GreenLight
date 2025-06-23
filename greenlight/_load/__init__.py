"""
GreenLight/greenlight/_load/__init__.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

A package for loading model definitions and input data onto a GreenLightInternal object.

Public functions:
    - load_model: Load a model in a GreenLightInternal object based on the object's input_prompt

Modules:
    - core: Functions for loading a model description from input files, dicts, and strings into a GreenLightInternal object.
    - _parse_model: Functions for parsing a model stored in a GreenLightInternal object and reformatting it
        according to predefined settings
    - _expand_functions: Functions for parsing model function calls and definitions in a GreenLightInternal object.
    - _utils: Functions for performing small tasks
"""

from .core import load_model

__all__ = ["load_model"]
