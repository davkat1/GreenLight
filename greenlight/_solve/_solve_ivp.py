"""
GreenLight/greenlight/_solve/_solve_ivp.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Solve a model defined in a GreenLightInternal instance using scipy.integrate.solve_ivp

This class is used for solving a GreenLightInternal mdl if mdl.options["solving_method"] == "solve_ivp"

Public functions:
    SolveIvp._solve(mdl: GreenLightInternal) -> None:
        Implements greenlight._solve._solver.Solve using scipy.integrate.solve_ivp
"""

import logging
import sys
import warnings
from typing import Tuple

import numexpr as ne
import numpy as np
from scipy.integrate import solve_ivp

from greenlight._greenlight_internal import GreenLightInternal

from ._solver import Solver


class SolveIvp(Solver):
    @staticmethod
    def solve(mdl: GreenLightInternal) -> None:
        """
        Run the simulation for a GreenLightInternal mdl using scipy.integrate.solve_ivp.
        Implements Solver._solve and follows all its requirements (see docs for Solver._solve)
        This implementation makes direct use of scipy.integrate.solve_ivp.

        If mdl.options["expand_variables"] is "false", the method calculates all the variable of mdl directly at each
        calculated timestep. These calculations are stored in mdl.full_sol.

        Besides numerical runtime warnings that are issued by scipy.integrate.solve_ivp, this method also issues
        warnings if large numbers are clipped (if mdl.options["clip_large_nums"] is "True") and if NaNs are replaced
        by zeros (if mdl.options["nans_to_zeros"] is "True").

        Note: it has been found that in some cases, some RuntimeWarnings are not caught by this solver, and therefore
        not added to the simulation log. Switching solver from "BDF" to "LSODA" seems to help with this.

        This method is used if mdl.options["solving_method"] == "solve_ivp"

        :param mdl: A GreenLightInternal instance which contains model definitions and options and is ready to be solved.
        :raise: An Exception if the interpretation of a variable failed
        :return: None
        """
        # Workspace where computations occur
        computation_space = {}

        # Import required packages to computation_space
        if mdl.options["formatting_mode"] == "numpy":
            exec("import numpy as np", computation_space)
        if mdl.options["formatting_mode"] == "math":
            exec("import math", computation_space)

        # load the initial values
        y0 = np.empty(len(mdl.states))
        for index, (key, value) in enumerate(mdl.states.items()):
            y0[index] = mdl.init[key]

        if mdl.options["expand_functions"].strip().lower() == "false":
            # Functions are not parsed, they need to be loaded to computation_space
            for key in mdl.functions.keys():
                exec(f"def {key}: return {mdl.variables_formatted[key]}", computation_space)

        # Set up the arguments for solve_ivp

        # If mdl.options["t_eval"] is "None", use None. Otherwise, use time points from mdl.options["t_start"]
        # to mdl.options["t_end"], with steps mdl.options["output_step"]
        if mdl.options["t_eval"] == "None":
            t_eval = None
        else:
            t_eval = np.arange(
                float(mdl.options["t_start"]), float(mdl.options["t_end"]), float(mdl.options["output_step"])
            )

        # If mdl.options["first_step"] was defined as a number, use that one, if not, use None
        try:
            first_step = float(mdl.options["first_step"])
        except ValueError:  # string could not be converted to float
            first_step = None

        warning_log = []

        # Create a function wrapper which includes the ODEs but also logs warnings
        # Note: some warnings raised will not be caught and logged, this is a limitation of solve_ivp
        def warn_logging_wrapper(fun):
            issue_warnings = mdl.options["warn_runtime"].strip().lower() == "true"

            def wrapped(t, y, *args):
                with np.errstate(all="warn"):  # Try to force NumPy to issue warnings
                    with warnings.catch_warnings(record=True) as w:  # Catch warnings
                        warnings.simplefilter("always")
                        result = fun(t, y, *args)

                        for issued_warning in w:
                            warn_msg = f"{issued_warning.category.__name__} encountered at time t={t}: {issued_warning.message}"
                            warning_log.append(warn_msg)

                if issue_warnings:
                    for issued_warning in w:
                        warn_msg = (
                            f"\n{issued_warning.category.__name__} encountered at time t={t}: {issued_warning.message}"
                        )
                        warnings.warn(warn_msg, category=issued_warning.category)

                return result

            return wrapped

        wrapped_ode = warn_logging_wrapper(SolveIvp._differentiate)

        # Solve the ODEs, catching and logging warnings in the process
        sol = solve_ivp(
            wrapped_ode,
            [float(mdl.options["t_start"]), float(mdl.options["t_end"])],
            y0,
            mdl.options["solver"],
            t_eval=t_eval,
            first_step=first_step,
            max_step=float(mdl.options["max_step"]),
            atol=float(mdl.options["atol"]),
            rtol=float(mdl.options["rtol"]),
            args=[mdl, computation_space, [float(mdl.options["t_start"]), float(mdl.options["t_end"])]],
        )

        if mdl.options["log_runtime_warnings"].strip().lower() == "true":
            # Add the logged warnings to mdl
            mdl.add_to_log("\n".join(set(warning_log)), warn=False)

        mdl.states_sol = sol
        if "Time" in mdl.full_sol:
            mdl.full_sol = mdl.full_sol.sort_values(by="Time")

    @staticmethod
    def _differentiate(
        t: float, y: np.ndarray, mdl: GreenLightInternal, computation_space: dict, t_span: Tuple[float, float]
    ) -> np.ndarray:
        """
        Differential equation for the GreenLightInternal mdl. Given a time t and a vector of state values y,
        returns a vector of the rate of change of states dy. This function is meant to be used as an argument for
        scipy.integrate.solve_ivp

        If mdl.options["expand_variables"] is "false", all model variables are directly calculated.
        Their values are stored in a pandas DataFrame as mdl.full_sol. This DataFrame is not sorted by time.

        The following attributes of mdl are modified:
            - mdl.full_sol: If mdl.options["expand_variables"].strip().lower() == "false", a row is added to mdl.full_sol.
                containing the values of all model variables (all values in mdl.solving_order) at time t
            - mdl.log: Modified to include numerical corrections performed: clipping of large values or replacing NaNs

        :param t: Time point in the simulation
        :param y: Value of the state vectors at time t
        :param mdl: GreenLightInternal instance describing the definitions of the states y, with mdl.options containing options for
                    differentiation
        :param computation_space: dict of local variables where computation occurs (used as local_dict argument for exec)
        :param t_span: A list of two floats, the start time and end time of the full simulation.
                        Used to display the progress in solving
        :return dy: The rate of change of the states y at time point t
        """
        # Get data from input data array
        if mdl.options["interpolation"] == "linear":  # Use linear interpolation
            # Multi-column version of np.interp
            # Based on answer of user Daniel F on stackoverflow
            # https://stackoverflow.com/questions/43772218/fastest-way-to-use-numpy-interp-on-a-2-d-array/43775224#43775224
            input_row = (mdl.input_data[mdl.input_data.columns[0]]).searchsorted(t) - 1
            if input_row <= 0:
                interp_row = mdl.input_data.iloc[0]
            elif input_row >= mdl.input_data.shape[0] - 1:
                interp_row = mdl.input_data.iloc[-1]
            else:
                delta = (t - mdl.input_data.iloc[input_row, 0]) / (
                    mdl.input_data.iloc[input_row + 1, 0] - mdl.input_data.iloc[input_row, 0]
                )
                interp_row = (1 - delta) * mdl.input_data.iloc[input_row] + delta * mdl.input_data.iloc[input_row + 1]
            computation_space = computation_space | interp_row.to_dict()
        else:  # Default value is "left", find the nearest value to the left
            input_row = (mdl.input_data[mdl.input_data.columns[0]]).searchsorted(t) - 1
            input_row = np.clip(input_row, 0, mdl.input_data.shape[0] - 1)
            computation_space = computation_space | mdl.input_data.loc[input_row].to_dict()

        # Load state values from y
        for i, (var_name, value) in enumerate(mdl.states.items()):
            if mdl.options["clip_large_nums"].strip().lower() == "true":
                y[i] = np.clip(y[i], -1e38, 1e38)

            computation_space[var_name] = y[i]

        # If variables were not expanded, calculate them and add them to mdl.full_sol
        if mdl.options["expand_variables"].strip().lower() == "false":
            for var_name in mdl.solving_order:
                if var_name not in mdl.states.keys() | mdl.input_data.columns:
                    expression = mdl.variables_formatted[var_name]
                    try:
                        logger = logging.getLogger(__name__)
                        if mdl.options["formatting_mode"] == "numexpr":
                            computation_space[var_name] = ne.evaluate(
                                expression,
                                local_dict=computation_space,
                            )
                        else:
                            exec(compile(var_name + " = " + expression, "<string>", "exec"), computation_space)
                    except Exception:
                        logger.error(
                            "Failed to interpret definition for %r: %r"
                            % (
                                var_name,
                                mdl.variables_formatted[var_name],
                            )
                        )
                        raise

                    # Replaces NaNs and infs by calculable values
                    # This helps the solver continue working and reduces computational errors
                    issue_warnings = mdl.options["warn_runtime"].strip().lower() == "true"
                    if mdl.options["nans_to_zeros"].strip().lower() == "true":
                        if np.isnan(computation_space[var_name]):
                            mdl.add_to_log(f"{var_name} is NaN at time {t}; replaced with 0", warn=issue_warnings)
                            computation_space[var_name] = 0
                        elif np.isposinf(computation_space[var_name]):
                            mdl.add_to_log(f"{var_name} is +inf at time {t}; replaced with 1e38", warn=issue_warnings)
                            computation_space[var_name] = 1e38
                        elif np.isneginf(computation_space[var_name]):
                            mdl.add_to_log(f"{var_name} is -inf at time {t}; replaced with -1e38", warn=issue_warnings)
                            computation_space[var_name] = -1e38

                    # Replace large values with values within the range -1e38 to 1e38
                    # This helps the solver continue working and reduces computational errors
                    if mdl.options["clip_large_nums"].strip().lower() == "true":
                        if computation_space[var_name] > 1e38:
                            mdl.add_to_log(
                                f"{var_name} is greater than 1e38 at time {t}; replaced with 1e38", warn=issue_warnings
                            )
                            computation_space[var_name] = 1e38
                        if computation_space[var_name] < -1e38:
                            mdl.add_to_log(
                                f"{var_name} is smaller than -1e38 at time {t}; replaced with -1e38",
                                warn=issue_warnings,
                            )
                            computation_space[var_name] = -1e38

            sol_t = np.empty(len(mdl.full_sol.columns))  # the solution at time point t
            for i, col_name in enumerate(mdl.full_sol.columns):
                if col_name == "Time":
                    sol_t[i] = t
                else:
                    sol_t[i] = computation_space[col_name]

            row = mdl.full_sol.index[mdl.full_sol["Time"] == t].tolist()
            if row:  # the time t has been computed before, replace it
                mdl.full_sol.loc[row[0]] = sol_t
            else:  # add a new row
                mdl.full_sol.loc[len(mdl.full_sol.index)] = sol_t

        # Calculate the values of the change of states and set them as dy
        dy = np.empty(len(mdl.states))
        for i, (var_name, value) in enumerate(mdl.states.items()):
            expression = mdl.variables_formatted[var_name]
            try:
                logger = logging.getLogger(__name__)
                if mdl.options["formatting_mode"] == "numexpr":
                    computation_space["dy"] = ne.evaluate(
                        expression,
                        local_dict=computation_space,
                    )
                else:
                    exec(compile("dy = " + expression, "<string>", "exec"), computation_space)
            except Exception:
                logger.error(
                    "Failed to interpret definition for %r: %r"
                    % (
                        var_name,
                        mdl.variables_formatted[var_name],
                    )
                )
                raise

            # Replace NaNs and Infs by calculable values
            if np.isnan(computation_space["dy"]) and mdl.options["nans_to_zeros"].strip().lower() == "true":
                mdl.add_to_log(f"Derivative of {var_name} is NaN at time {t}. Replaced with 0", warn=issue_warnings)
                computation_space["dy"] = 0
            elif np.isposinf(computation_space["dy"]) and mdl.options["clip_large_nums"].strip().lower() == "true":
                mdl.add_to_log(f"Derivative of {var_name} is inf at time {t}. Replaced with 1e38", warn=issue_warnings)
                computation_space["dy"] = 1e38
            elif np.isneginf(computation_space["dy"]) and mdl.options["clip_large_nums"].strip().lower() == "true":
                mdl.add_to_log(
                    f"Derivative of {var_name} is -inf at time {t}. Replaced with -1e38", warn=issue_warnings
                )
                computation_space["dy"] = -1e38

            dy[i] = computation_space["dy"]

        # Print out progress. Thanks Simon Luzara from stackoverflow: https://stackoverflow.com/a/72363754
        print(
            "\rRunning: "
            + str(format(np.minimum(100, ((t - t_span[0]) / (t_span[1] - t_span[0])) * 100), ".2f"))
            + "%",
            end="",
        )
        sys.stdout.flush()
        return dy
