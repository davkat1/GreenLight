"""
GreenLight/greenlight/_solve/_solve_ivp_from_str.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Solve a model defined in a GreenLightInternal mdl by defining a new Python function from the strings in mdl.commands,
and using scipy.integrate.solve_ivp

This class is used for solving a GreenLightInternal mdl if mdl.options["solving_method"] == "solve_ivp_from_str"

Public functions:
    SolveIvpFromStr._solve(mdl: GreenLightInternal) -> None:
        Implements greenlight._solve._solver.Solve by defining a new Python function from the strings in mdl.commands,
        and using scipy.integrate.solve_ivp
"""

import warnings

import numpy as np
from scipy.integrate import solve_ivp

from greenlight._greenlight_internal import GreenLightInternal

from ._solver import Solver


class SolveIvpFromStr(Solver):
    @staticmethod
    def solve(mdl: GreenLightInternal) -> None:
        """
        Run the simulation for a GreenLightInternal instance by creating a new Python function using mdl.commands.
        Then solve the ODEs using the new function, with scipy.integrate.solve_ivp.

        This method is used if mdl.options["solving_method"] == "solve_ivp_from_str"

        Implements Solver._solve and follows all its requirements (see docs for Solver._solve)
        Currently this method is not supported with mdl.options["expand_variables"] == "True" (case insensitive)
        If it is True, a ValueError is raised.

        Note that as opposed to _solve_ivp.py, the method here does not issue warnings if large numbers are clipped
        (if mdl.options["clip_large_nums"] is "True") or if NaNs are replaced by zeros
        (if mdl.options["nans_to_zeros"] is "True"). This is a choice made to improve running speed.

        Note: it has been found that in some cases, some RuntimeWarnings are not caught by this solver, and therefore
        not added to the simulation log. Switching solver from "BDF" to "LSODA" seems to help with this somewhat.

        :param mdl: A GreenLightInternal instance which contains model definitions and options and is ready to be solved.
        :raise: ValueError if mdl.options["expand_variables"] is not true,
                An Exception if the solving failed for any other reason
        :return: None
        """
        # Workspace where computations occur
        computation_space = {}

        # Import required packages to computation_space
        exec("import numpy as np", computation_space)
        if mdl.options["formatting_mode"] == "math":
            exec("import math", computation_space)

        # load the initial values
        y0 = np.empty(len(mdl.states))
        for index, (key, value) in enumerate(mdl.states.items()):
            y0[index] = mdl.init[key]

        # "expand_variables" is currently not supported with solve_ivp_from_str -
        # it creates errors and hasn't been thoroughly tested
        if mdl.options["expand_variables"].strip().lower() == "true":
            raise ValueError("'expand_variables' is not supported with 'solve_ivp_from_str'")

        # Convert mdl.input_data from DataFrame to 2D numpy array
        input_array = []
        if "Time" in mdl.input_data.keys():  # If there is any input data, there should also be a "Time" column
            input_array = mdl.input_data["Time"].to_numpy().reshape(-1, 1)
        for j, (input_var_name) in enumerate(mdl.inputs.keys()):
            if input_var_name != "Time":
                input_array = np.hstack((input_array, mdl.input_data[input_var_name].to_numpy().reshape(-1, 1)))

        # Dummy function to allow the script to run compiling
        def dy_from_str(t, y, d_matrix, t_span):
            return 0

        # Create a string in the form of a Python script defining a function
        # This is the function that will be used as an argument for scipy.integrate.solve_ivp
        func_str = "def dy_from_str(t, y, d_matrix, t_span):\n"
        func_str = func_str + "\tdy = np.zeros(y.shape)\n"

        if mdl.options["interpolation"] == "linear":  # Use linear interpolation
            # Multi-column version of np.interp
            # Thanks user Daniel F on stackoverflow
            # https://stackoverflow.com/questions/43772218/fastest-way-to-use-numpy-interp-on-a-2-d-array/43775224#43775224
            def multi_interp2(x, xp, fp):
                j = np.searchsorted(xp, x) - 1
                if j <= 0:
                    return fp[0, :]
                elif j >= xp.shape[0] - 1:
                    return fp[-1, :]
                else:
                    d = (x - xp[j]) / (xp[j + 1] - xp[j])
                    return (1 - d) * fp[j, :] + d * fp[j + 1, :]

            computation_space["multi_interp2"] = multi_interp2
            func_str = func_str + "\td = np.concatenate(([t], multi_interp2(t, d_matrix[:,0], d_matrix[:,1:])))\n"
        else:  # Default is interpolate left
            func_str = func_str + (
                "\trow = np.searchsorted(d_matrix[:,0], t)-1\n"
                + "\trow = np.clip(row, 0, d_matrix.shape[0]-1)\n"
                + "\td = d_matrix[row,:]\n"
            )

        # Use the model commands stored in mdl.commands to define the Python function
        func_str = func_str + (
            "\ta = np.zeros(" + str(len(mdl.solving_order)) + ")\n" + "\t" + "\n\t".join(mdl.commands) + "\n"
        )

        # Replace NaNs and inf's by calculable values -
        # This helps the solver continue working and reduces computational errors
        # Note: for the sake of improving running time, this action is not logged and no warning is issued
        if mdl.options["nans_to_zeros"].strip().lower() == "true":
            func_str = func_str + "\n\ty[np.isnan(y)] = 0"
            func_str = func_str + "\n\tdy[np.isnan(dy)] = 0"
            func_str = func_str + "\n\ta[np.isnan(a)] = 0"

        # Replace large values with values within the range -1e38 to 1e38
        # This helps the solver continue working and reduces computational errors
        # Note: for the sake of improving running time, this action is not logged and no warning is issued
        if mdl.options["clip_large_nums"].strip().lower() == "true":
            func_str = func_str + "\n\ty = np.clip(y, -1e38, 1e38)"
            func_str = func_str + "\n\tdy = np.clip(dy, -1e38, 1e38)"
            func_str = func_str + "\n\ta = np.clip(a, -1e38, 1e38)"

        # Print out progress. Thanks Simon Luzara from stackoverflow:
        # https://stackoverflow.com/a/72363754
        func_str = func_str + (
            "\n\tprint("
            + "'\\rRunning: ' "
            + " + str(format(np.minimum(100, ((t - t_span[0]) / (t_span[1] - t_span[0])) * 100), '.2f'))"
            + "+'%', end='',)\n"
        )

        func_str = func_str + "\n\treturn dy"

        mdl.add_to_log("Model definitions converted to Python function:", warn=False)
        mdl.add_to_log(func_str, warn=False)

        exec(func_str, computation_space)

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
        # Note: some warnings issued will not be caught and logged, this is a limitation of solve_ivp
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
                            warn_msg = f"\n{issued_warning.category.__name__} encountered at time t={t}: {issued_warning.message}"
                            warnings.warn(warn_msg, category=issued_warning.category)

                    return result

            return wrapped

        wrapped_ode = warn_logging_wrapper(computation_space["dy_from_str"])

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
            args=[input_array, [float(mdl.options["t_start"]), float(mdl.options["t_end"])]],
        )

        if mdl.options["log_runtime_warnings"].strip().lower() == "true":
            # Add the logged warnings to mdl
            mdl.add_to_log("\n".join(set(warning_log)), warn=False)

        mdl.states_sol = sol
