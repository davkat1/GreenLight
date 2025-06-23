"""
GreenLight/greenlight/_solve/__init__.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

A package for running simulations stored in a GreenLightInternal object by solving a set of ODEs

Public functions:
    - core.solve_model(mdl: GreenLightInternal) -> None
        Run the simulation for a GreenLightInternal mdl and store the solution in mdl.full_sol as a pandas DataFrame

Modules:
    - core: Functions for solving the model according to a fixed format and workflow
    - _solver: Defines the abstract class Solve which defines the requirement for solving classes
    - _solve_ivp: Defines the class SolveIvp which inherits Solve and solves using scipy.integrate.solve_ivp
    - _solve_ivp_from_str: Defines class SolveIvpFromStr which inherits Solve and solves by defining a new
        Python function and then uses scipy.integrate.solve_ivp
"""

from .core import solve_model

__all__ = ["solve_model"]
