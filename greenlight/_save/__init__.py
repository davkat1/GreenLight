"""
GreenLight/greenlight/_save/__init__.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

A package for saving simulation results and log from a GreenLight object to files

Public functions:
    - core.save_sim(mdl: GreenLight) -> None
        Save the simulation of a GreenLight model and related logs in files

Modules:
    - core: Functions for saving the results and logs from a GreenLight model run
"""

from .core import save_sim

__all__ = ["save_sim"]
