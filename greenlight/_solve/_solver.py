"""
GreenLight/greenlight/_solve/_solver.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Defines an abstract class Solver for solving a model (i.e., running the simulation) defined in a GreenLightInternal instance.

Public functions:
    Solver._solve(mdl: GreenLightInternal) -> None: (abstract)
        Run the simulation for a GreenLightInternal mdl and store the solution in mdl.full_sol as a pandas DataFrame

Exceptions:
    An Exception is raised if the solving failed
"""

from abc import ABC, abstractmethod

from greenlight._greenlight_internal import GreenLightInternal


class Solver(ABC):
    @staticmethod
    @abstractmethod
    def solve(mdl: GreenLightInternal) -> None:
        """
        An abstract method for running the simulation for a GreenLightInternal mdl by solving ths ODEs defined in mdl.
        Classes implementing this method should solve the ODEs defined in mdl.states and store the solution by modifying
        the attributes of mdl. After running this method, mdl should be modified as follows:
            - mdl.states_sol: should contain the solution in a bunch object, in the same format as the returned value of
                scipy.integrate.solve_ivp. For more info, see:
                https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_ivp.html
            - mdl.full_sol: depending on the solving method, this may be filled with the values of all model variables
                (all values in mdl.solving_order), sorted by time, from mdl.options["t_start"] to mdl.options["t_end"].
                Alternatively, it may be an empty DataFrame, which is filled later by _solve.solve_model.
            - mdl.log: should be modified to include information about the solving process and any RuntimeWarnings
                encountered. For example, information about numerical corrections performed: clipping of large values
                or replacement of Infs and NaNs. See more about RuntimeWarnings below.

        The details of what is calculated and how should depend on mdl.options, see also docs/simulations_options.md:
            - mdl.options["t_eval"]: attribute controlling the time points in which the solver should evaluate the ODEs.
                If this value is "None", the solver should be free to choose the evaluation points.
                Otherwise, the evaluation points should be from mdl.options["t_start"] to mdl.options["t_end"],
                with intervals of mdl.options["output_step"]
            - mdl.options["first_step"]: size of first step to be used by the solver. If it is a numerical value, this is
                the value that should be used by the solver as the initial value for the first step. Otherwise, the
                solver can freely choose the first step size.
            - mdl.options["interpolation"]: if it is "linear", linear interpolation should be used for interpolating
                model input data. Otherwise, "nearest neighbour" to the left should be used.
            - mdl.options["clip_large_nums"]: if "true" (case insensitive), values should be clipped
                to the range of [-1e38, 1e38]. This may help prevent computation errors.
            - mdl.options["nans_to_zeros"]: : if "true" (case insensitive), any NaN encountered during solving should
                be replaced by 0. This may help prevent computation errors.
            - mdl.options["expand_variables"]: if "true" (case insensitive), it can be assumed that expressions for the
                model states are fully expanded, and can be calculated directly, i.e., there is no need to calculate
                auxiliary states.
                If the value is false, it should be assumed that variables have not been expanded to their full
                mathematical expressions. Therefore, all variables (including auxiliary states) should be calculated.
                In this case, the method should store the calculations in mdl.full_sol.
            - mdl.options["expand_functions"]: if "true" (case insensitive), it can assumed that expressions for model
                functions are fully expanded, therefore model functions do not need to be calculated.
                Otherwise, model functions should be directly calculated.
            - mdl.options["formatting_mode"]:
                If it is "numpy", it can be assumed that all mathematical expressions "<e>" are formatted as "np.<e>".
                If it is "math", it can be assumed that all mathematical expressions "<e>" are formatted as "math.<e>".
                If it is "numexpr", it can be assumed that all mathematical expressions are formatted in a way that
                can be interpreted by the numexpr package.
                See docs/math_expressions.md for a list of what is considered mathematical expressions.

        The solver should also log warnings that are issued during solving:
            - If options["warn_runtime"] is "true" (case insensitive), warnings issued during solving should be issued
                out to the console. Otherwise, warnings should be caught and not issued to the console.
            - If options["log_runtime_warnings"] is "true" (case insensitive), warnings should be added to mdl.log,
                regardless of whether they were caught or not
        However, note that sometimes solvers fail to catch warnings, in this case the warnings will not be logged.
        In order to supress all warnings manually, use warnings.filterwarnings("ignore")
        See the documentation of the solvers for more information.


        :param mdl: A GreenLightInternal instance which contains model definitions and options and is ready to be solved.
        :raise: An Exception if the solving failed for whatever reason
        :return: None
        """
        pass
