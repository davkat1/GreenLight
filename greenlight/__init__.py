"""
GreenLight/greenlight/__init__.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Top-level package for greenlight -
    A platform for creating, modifying, and combining dynamic models,
    with a focus on horticultural greenhouses and crops.

Modules:
    - core.py: Defines the GreenLight class, which holds a GreenLight model
    - utils.py: Utilities functions for working with GreenLight
    - main.py: Initial access to the package, with example functionality
    - energy_plus: Functions for converting an EnergyPlus CSV file to an input file that can be used by
        the GreenLight model (Katzin 2020, Katzin 2021).
    - _greenlight_internal.py: Definition of the GreenLightInternal class

Sub-packages:
    - _load: Methods for loading model definition and input data onto a GreenLight object
    - _solve: Methods for performing a dynamic simulation of a loaded GreenLight object
    - _save: Methods for saving information throughout the simulation and writing them to file

Public classes:
    - GreenLight: Class for handling and running dynamic simulations

Public methods:
    - convert_energy_plus: Convert an EnergyPlus weather file from EnergyPlus' CSV format to the format needed by
        the GreenLight model (Katzin 2020, Katzin 2021)
    - copy_builtin_models: Copy the built-in model files included in the greenlight package to a user-provided location
"""

__author__ = "David Katzin, Wageningen University & Research"
__email__ = "david.katzin@wur.nl"

# Get version number from pyproject.toml
try:
    from importlib.metadata import version
except ImportError:
    # For Python <3.8 compatibility (optional)
    from importlib_metadata import version

try:
    __version__ = version("greenlight")
except Exception:
    __version__ = "unknown"

from .core import GreenLight
from .energy_plus import convert_energy_plus
from .utils import copy_builtin_models

__all__ = ["GreenLight", "convert_energy_plus", "copy_builtin_models"]
