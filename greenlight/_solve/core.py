"""
GreenLight/greenlight/_solve/core.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Functions for solving a model (i.e., running the simulation) defined in a GreenLightModel instance.

Public functions:
    solve_model(mdl: GreenLightModel) -> None:
        Run the simulation for a GreenLightModel mdl and store the solution in mdl.full_sol

Example usage:
    >>> from greenlight._greenlight_internal import GreenLightInternal
    >>> mdl = GreenLightInternal("C:\\Models", "my_model.json")
    >>> load_model(mdl)
    >>> solve_model(mdl)

Exceptions:
    Exceptions are raised if the solving failed for whatever reason

External dependencies:
    - numexpr: for fast computation of mathematical expressions represented as strings
    - numpy: for working with numerical arrays
    - pandas: for loading data from input CSV files, and for representing the model solution
"""

import datetime
import logging
import time

import numexpr as ne
import numpy as np
import pandas as pd

from greenlight._greenlight_internal import GreenLightInternal

from . import _solve_ivp, _solve_ivp_from_str


def solve_model(mdl: GreenLightInternal) -> None:
    """
    Solve the GreenLightInternal mdl based on the model definitions and options set in it
    (typically using greenlight.load_model). After running this function, the following attributes of mdl are modified:
        - mdl.states_sol: contains the model solution in a Bunch object, in the same format as the returned value of
            scipy.integrate.solve_ivp.  For more info, see:
                https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_ivp.html
        - mdl.full_sol: is a pandas DataFrame containing the full model solution: a pandas DataFrame with the first
        column as "Time", and the next columns representing all model variables, with their solved values through time
        - mdl.log: is appended with information about the solving process. For example, information
            about numerical corrections performed or warnings issued

    The calculation method depends on sim.options. The following methods are currently implemented:
        If sim.options["solving_method"] == "solve_ivp", greenlight._solve._solve_ivp is used
        If sim.options["solving_method"] == "solve_ivp_from_str", greenlight._solve._solve_ivp_from_str is used
            _solve._solve_ivp.py

    The solver should also log warnings that are issued during solving:
            - If options["warn_runtime"] is "true" (case insensitive), warnings issued during solving should be issued
                out to the console. Otherwise, warnings should be caught and not issued to the console.
            - If options["log_runtime_warnings"] is "true" (case insensitive), warnings should be added to mdl.log,
                regardless of whether they were caught or not
        However, note that sometimes solvers fail to catch warnings, in this case the warnings will not be logged.
        In order to supress all warnings manually, use warnings.filterwarnings("ignore")

    :param mdl: A GreenLightInternal instance with model definitions and options as set by greenlight._load.load_model()
    :raise: An Exception if the solving failed for whatever reason
    :return: None
    """

    start_time = time.time()
    mdl.add_to_log(
        f"Simulation started at time (ISO format): {datetime.datetime.now().isoformat()}", warn=False, to_print=True
    )

    if mdl.options["solving_method"] == "solve_ivp":
        _solve_ivp.SolveIvp.solve(mdl)
    elif mdl.options["solving_method"] == "solve_ivp_from_str":
        _solve_ivp_from_str.SolveIvpFromStr.solve(mdl)
    else:
        raise ValueError(f"solving method {mdl.options['solving_method']} not found")

    # If auxiliary states were not directly calculated, do it now
    if mdl.full_sol["Time"].empty:
        _compute_full_solution(mdl)

    # Enforce a column order
    col_order = (
        (["Time"] if "Time" in mdl.full_sol.columns else [])  # Time
        + list(mdl.states.keys())  # Then states
        + [col for col in mdl.input_data.columns if col != "Time"]  # Then inputs
        + [key for key in mdl.solving_order if key in mdl.aux and key != "Time"]
        # Then auxiliary states, according to solving order
    )
    mdl.full_sol = mdl.full_sol[col_order]

    end_time = time.time()
    print("\n")
    if mdl.states_sol.success:
        mdl.add_to_log(
            f"Simulation complete at time (ISO format): {datetime.datetime.now().isoformat()}",
            warn=False,
            to_print=True,
        )
    else:
        mdl.add_to_log(
            f"Simulation failed at time t={mdl.states_sol.t[-1]}: {mdl.states_sol.message}", warn=True, to_print=True
        )

    mdl.add_to_log(f"Simulated {(mdl.states_sol.t[-1] - mdl.states_sol.t[0]) / 86400} days", warn=False, to_print=True)
    mdl.add_to_log(f"Elapsed time: {end_time - start_time} seconds", warn=False, to_print=True)


def _compute_full_solution(mdl: GreenLightInternal) -> None:
    """
    Depending on the solver and solver settings used, after simulation it could be that only state
    variables were calculated, and other variables (like auxiliary states) have not been directly calculated.
    In this case, this function computes all variables, based on the values of the state variables, which were
    calculated using solve_model._solve()

    This function fills sim.full_sol, which is a pandas DataFrame containing values
    for all model states, inputs, and auxiliary states, with values according to the time trajectory of the states
    that are in sim.states_sol

    The calculation method depends on sim.options, see solve_model._solve() for more information.

    :param mdl: A GreenLightInternal object that has already been solved using solve_model._solve().
                Typically sim.options["expand_variables"] is true, so most variables have been expanded
                but not calculated
    :raise: An Exception if the interpretation of a variable failed
    :return: None
    :rtype: None
    """
    # Time stamps of the solution
    full_sol = {"Time": mdl.states_sol.t}

    # Values of the model states (solved by the ODE solver)
    for index, (key, value) in enumerate(mdl.states.items()):
        full_sol[f"{key}"] = mdl.states_sol.y[index]

    # Get data from input data file - interpolated to time points states_sol.t
    for col_idx in range(1, len(mdl.input_data.columns)):
        var_name = mdl.input_data.columns[col_idx]
        if mdl.options["interpolation"] == "linear":
            # Linear interpolation is used if set in the options,
            full_sol[var_name] = np.interp(
                mdl.states_sol.t,
                mdl.input_data[mdl.input_data.columns[0]],
                mdl.input_data[mdl.input_data.columns[col_idx]],
            )
        else:  # Default value is "left", find the nearest value to the left
            input_rows = (mdl.input_data[mdl.input_data.columns[0]]).searchsorted(mdl.states_sol.t) - 1
            input_rows = np.clip(input_rows, 0, len(mdl.input_data) - 1)
            full_sol[var_name] = mdl.input_data.loc[input_rows, var_name].to_numpy()

    if mdl.options["formatting_mode"] == "numpy":
        exec("import numpy as np", full_sol)
    if mdl.options["formatting_mode"] == "math":
        exec("import math", full_sol)

    # Calculate values for all variables. Ones that are not aux states will be removed
    keys_to_remove = []
    for key in mdl.solving_order:
        if key not in mdl.aux and key not in mdl.input_data.columns:
            keys_to_remove.append(key)

        try:
            logger = logging.getLogger(__name__)
            if mdl.options["formatting_mode"] == "numexpr":
                full_sol[key] = ne.evaluate(mdl.variables_formatted[key], local_dict=full_sol)
            else:
                exec(key + " = " + mdl.variables_formatted[key], full_sol)
        except Exception:
            logger.error(
                "Failed to interpret definition for %r: %r"
                % (
                    key,
                    mdl.variables_formatted[key],
                )
            )
            raise

    # Remove elements from full_sol that shouldn't be saved
    keys_to_remove.extend(["np", "math", "__builtins__", "__warningregistry__"])

    # Save a DataFrame of full_sol as mdl.full_sol
    mdl.full_sol = pd.DataFrame({key: value for (key, value) in full_sol.items() if key not in keys_to_remove})
