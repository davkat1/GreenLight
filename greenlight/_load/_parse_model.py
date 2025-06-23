"""
GreenLight/greenlight/_load/_parse_model.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Functions for parsing a model stored in a GreenLightInternal object and reformatting it according to predefined settings

Public functions:
    format_expressions(all_expressions, basis_expressions, functions,
        formatting_mode, perform_function_parsing, perform_variable_parsing) -> (dict[str, str], dict, list):
        Format all_expressions according to formatting_mode and the other parameters.
    extract_variables(node, extracted_type, node_name) -> dict:
        Create a dictionary of model variables of extracted_type defined under a dict node. Recurse through sub-nodes.
        Return dict of variable definitions, units, descriptions, and references.
    extract_options(node, extracted_type, node_name) -> dict:
        Create a dictionary of model options based on any options defined in node. Recurse through sub-nodes.
        Return dict containing all model options.

Exceptions:
    ValueError if circular dependencies are found
    ValueError if unrecognized formatting_mode given to format_expressions
    ValueError if dict with a duplicate definition (two definitions for the same variable) given to extract_variables

External dependencies:
    - None
"""

import copy
import re
from typing import Iterable

from . import _expand_functions
from ._utils import check_for_cycles, find_dependencies


def format_expressions(
    all_expressions: dict,
    basis_expressions: Iterable[str],
    functions: dict[str, str],
    formatting_mode: str,
    perform_function_parsing: bool,
    perform_variable_parsing: bool,
) -> (dict[str, str], dict, list):
    """
    Format the mathematical expressions in all_expressions according to formatting_mode and the additional parameters.
    This allows to later solve the model according to a chosen method. Note that some mathematical expressions,
    depending on formatting_mode, are considered "builtin" and will not be formattted. See docs/math_expressions.md
    for more info.

    Example usage:
        For a loaded GreenLightInternal mdl, format the variables, map the dependencies, and list the solving order,
        based on mdl's, variables, states, functions, and options:
        >>> mdl.variables_formatted, mdl.dependencies, mdl.solving_order = format_expressions(
        ...     mdl.variables, mdl.states.keys(), mdl.functions, mdl.options["formatting_mode"],
        ...     mdl.options["expand_functions"].strip().lower() == "true",
        ...     mdl.options["expand_variables"].strip().lower() == "true",
        ... )

    :param all_expressions: A dict describing variables. The keys are variable names and the values are mathematical
        expressions describing the variable and its relation to other variables.
        Typically these are the various model definitions.
    :param basis_expressions: The set of expressions with which the formatted expressions need to be expressed.
        Typically these are the model states, and possibly other expressions which need not be formatted.
    :param functions: A dict describing functions, e.g., {"func1(a,b)": "a + b**2"}.
        Typically these are functions described in the model definition.
    :param formatting_mode: The following modes are currently supported:
        "numpy": All numpy expressions <e> will be formatted as "np.<e>"
        "math": All math expressions <e> will be formatted as "math.<e>"
        "numexpr": Math expressions are not changed
    :param perform_function_parsing:
        If true, functions will be expanded to their full mathematical expression instead of calculated.
        For example, if functions is {"func1(a,b)": "a + b**2"}, then the expression
        "func1(x,y+z)" will be expanded to "x + (y+z)**2"
    :param perform_variable_parsing: if True, all_expressions will be expanded and expressed
        using only basis_expressions.
        For example, if basis_expressions is ["y1", "y2", "y3"],
        and all_expressions is {"v1": "v2 + y1", "v2": "y2*y3"},
        then the formatted expression will be {"v1": "y2*y3 + y1", "v2": "y2*y3"}.
        This should be possible to do for as long as no circular dependencies (v1 is described using v2
        which is described using v1) are found.
    :return:
        - formatted_expressions: A dictionary with the formatted expressions. The keys are the same as in
                all_expressions, but the values are formatted<br>
        - dependencies: For each key in all_expressions, dependencies[key] is a set containing the names of all
             expressions in all_expressions that key depends on.
                For example, if basis_expressions is ["y1", "y2", "y3"],
                and all_expressions is {"v1": "v2 + y1", "v2": "y2*y3"},
                then dependencies is {"v1": {"v2"}, "v2": set()}<br>
        - solving_order: A list of the keys of all_variables, sorted in a way that solving is possible
                (no variable is interpreted before all of its dependencies are interpreted)
    :raises: A ValueError is raised if circular dependencies are found (v1 depends on v2 which depends on v1)
             A ValueError is raised if formatting_mode is not a recognized value
    """

    # Expressions that do not get reformatted.
    # Based on https://numexpr.readthedocs.io/en/latest/user_guide.html#supported-functions
    # and some trial and error to check which other functions numexpr can evaluate
    math_expressions = [
        "sin",
        "cos",
        "tan",
        "sinh",
        "cosh",
        "tanh",
        "log",
        "log10",
        "log1p",
        "exp",
        "expm1",
        "sqrt",
        "floor",
        "ceil",
        "inf",
        "radians",
    ]

    numexpr_expressions = [
        "where",
        "arcsin",
        "arccos",
        "arctan",
        "arctan2",
        "arcsinh",
        "arccosh",
        "arctanh",
        "conj",
        "real",
        "imag",
        "complex",
        "contains",
        "abs",
        "mod",
        "logical_and",
        "logical_or",
    ]

    builtin_expressions = math_expressions + numexpr_expressions

    # numpy has all the above builtin_expressions
    numpy_expressions = builtin_expressions

    expressions_to_format = copy.deepcopy(all_expressions)  # The expressions that still need to be reformatted

    if perform_function_parsing:
        _expand_functions.parse(expressions_to_format, functions, builtin_expressions)

    # Create a dict of dependencies with dictionary comprehension using _find_dependencies
    dependencies = {
        key: find_dependencies(value, expressions_to_format.keys(), basis_expressions | builtin_expressions)
        for key, value in expressions_to_format.items()
    }

    # If the definition is simply the name of the variable, it's considered to have no dependencies
    # (these are typically inputs)
    for key, value in expressions_to_format.items():
        if key == value:
            dependencies[key] = set()

    # Check for circular dependencies. A ValueError will be raised if a circular dependency is found
    check_for_cycles(
        expressions_to_format.keys(), dependencies, basis_expressions | {key: key for key in builtin_expressions}
    )

    # The basis and builtin expressions are already considered expanded.  This is done so that in the next step,
    # when these expressions appear as dependencies, they are not further expanded
    formatted_expressions: dict[str, str] = {key: key for key in basis_expressions | builtin_expressions}
    solving_order = []

    while expressions_to_format:  # There are still expressions that need to be expanded
        for key in list(expressions_to_format):
            if all(dep in formatted_expressions for dep in dependencies[key]):  # All deps for this key are expanded...
                expression = expressions_to_format.pop(key)
                for dep in sorted(dependencies[key], key=len, reverse=True):
                    if perform_variable_parsing:
                        #                                       ...so simply replace each dependency by its expansion
                        expression = re.sub(r"\b%s\b" % dep, f"({formatted_expressions[dep]})", expression)
                formatted_expressions[key] = expression
                if key not in solving_order:
                    solving_order.append(key)

    # Bulitin expressions do not need to appear in formatted_expressions, so can now remove them
    for key in builtin_expressions:
        if key in formatted_expressions.keys():
            del formatted_expressions[key]

    if formatting_mode == "numpy":
        # Convert all numpy expressions from "expr" to "np.expr"
        for key, value in formatted_expressions.items():
            for numpy_expr in numpy_expressions:
                formatted_expressions[key] = re.sub(
                    r"\b%s\b" % numpy_expr, f"np.{numpy_expr}", formatted_expressions[key]
                )
    elif formatting_mode == "math":
        # Convert all math expressions from "expr" to "math.expr"
        for key, value in formatted_expressions.items():
            for math_expr in math_expressions:
                formatted_expressions[key] = re.sub(
                    r"\b%s\b" % math_expr, f"math.{math_expr}", formatted_expressions[key]
                )
    elif formatting_mode != "numexpr":
        raise ValueError("Unrecognized formatting mode %r" % formatting_mode)

    # Basis expressions and functions do not need to be solved
    for key in basis_expressions | functions.keys():
        if key in solving_order:
            solving_order.remove(key)

    return formatted_expressions, dependencies, solving_order


def extract_variables(node: dict, extracted_type: str = "all", node_name: str = "") -> dict:
    """
    Extract variables defined in node and all its sub-nodes. If node has a key "type" or "definition" it is assumed to
    contain a variable definition.
    In this case, if node["type"]==extracted_type, the key node_name will be added to the following dicts
    in the following way:
        defs_dict[node_name] = node["definition"]
        units_dict[node_name] = node["unit"]
        desc_dict[node_name] = node["description"]
        refs_dict[node_name] = node["reference"]

    One exception is if extracted_type == "init", in this case, the following will be assigned:
        defs_dict[node_name] = node["init"]

    If any of the above keys do not exist in node, default values will be used:
        The default definition is node_name
        The default unit is "no_unit_defined"
        The default description is ""
        The default reference is ""
    After this procedure, the function will continue recursively through all subnodes (i.e., values) in node.
    See docs/model_format.md for details on what the expected node structure.

    Example usage:
        For a given GreenLightInternal component described in a dict, extract the variables and their definitions:
        >>> new_variables = extract_variables(model_component, extracted_type="all")

    :param node: dict containing a variable definitions or subnodes with their own variable definitions
    :param extracted_type: If "all", all nodes will be included. If "initial value", the function will set
        defs_dict[node_name] as node["init"] (for setting initial values for states). For other values, the function
        will only consider nodes with node["type"]==extracted_type
    :param node_name: A name for the node, to be used as the key for the return dicts
    :return A dict in the following format:
        {"definition": defs_dict, "unit": units_dict, "description": desc_dict, "reference": refs_dict}
    :raises: A ValueError is raised if a duplicate definition (two definitions for the same variable) is found

    """
    defs_dict = {}
    units_dict = {}
    desc_dict = {}
    refs_dict = {}

    if isinstance(node, dict):
        if "type" in node or "definition" in node:  # The node represents a variable
            if extracted_type == "all" or ("type" in node and node["type"] == extracted_type):
                if "definition" in node:
                    defs_dict[node_name] = node["definition"]
                else:
                    defs_dict[node_name] = node_name
                if "unit" in node:
                    units_dict[node_name] = node["unit"]
                else:
                    units_dict[node_name] = "no_unit_defined"
                if "description" in node:
                    desc_dict[node_name] = node["description"]
                else:
                    desc_dict[node_name] = ""
                if "reference" in node:
                    refs_dict[node_name] = node["reference"]
                else:
                    refs_dict[node_name] = ""
        if extracted_type == "initial value" and "init" in node:
            defs_dict[node_name] = node["init"]
            if "unit" in node:
                units_dict[node_name] = node["unit"]
            else:
                units_dict[node_name] = "no_unit_defined"
            if "description" in node:
                desc_dict[node_name] = node["description"]
            else:
                desc_dict[node_name] = "no_description"
            if "reference" in node:
                refs_dict[node_name] = node["reference"]
            else:
                refs_dict[node_name] = ""

        # Recurse the function over all sub-nodes of the current node
        for key, value in node.items():
            sub_node = extract_variables(value, extracted_type, key)

            # Add all keys from sub-nodes into the parent node, raising an error in case of overwrite
            for sub_key, sub_value in sub_node["definition"].items():
                if sub_key in defs_dict:
                    raise ValueError(
                        "Duplicate definition for variable %r: %r and %r" % (sub_key, defs_dict[sub_key], sub_value)
                    )
                if sub_key in units_dict and units_dict[sub_key] != sub_node["unit"][sub_key]:
                    raise ValueError(
                        "Duplicate unit definition for variable %r: %r and %r"
                        % (sub_key, units_dict[sub_key], sub_node["unit"][sub_key])
                    )
                if sub_key in desc_dict and desc_dict[sub_key] != sub_node["description"][sub_key]:
                    raise ValueError(
                        "Duplicate description for variable %r: %r and %r"
                        % (sub_key, desc_dict[sub_key], sub_node["description"][sub_key])
                    )
                if sub_key in refs_dict and refs_dict[sub_key] != sub_node["reference"][sub_key]:
                    raise ValueError(
                        "Duplicate reference for variable %r: %r and %r"
                        % (sub_key, refs_dict[sub_key], sub_node["reference"][sub_key])
                    )
                else:
                    defs_dict[sub_key] = sub_value
                    units_dict[sub_key] = sub_node["unit"][sub_key]
                    desc_dict[sub_key] = sub_node["description"][sub_key]
                    refs_dict[sub_key] = sub_node["reference"][sub_key]

    return {"definition": defs_dict, "unit": units_dict, "description": desc_dict, "reference": refs_dict}


def extract_options(node: dict, node_name: str = "") -> dict:
    """
    Extract options contained in an options node. A node is considered an options node if its name
    (the key of the root node) is "Options" (case insensitive).
    The method goes through the given node and searches for options nodes. For any options nodes found, their
    subnodes are collected in the returned dict.
    The method recurses through all sub-nodes of node to collect any options defined.

    Example usage:
        >>> extract_options({"root": {
        ...                     "sub_node_1": {"options": {"t_start": "0"}},
        ...                     "sub_node_2": {"options": {"t_end": "86400"}}
        ...                       }})
        will return:
        >>> {"t_start": "0", "t_end": "86400"}

    :param node: A node of a dictionary to start searching for options nodes from
    :param node_name: The name of the node given. If it is "options" (case-insensitive),
        the node is considered an options node.
    :return: A dict with all the options defined in node and its sub-nodes.
    """
    options = {}

    if isinstance(node, dict):
        if node_name.strip().lower() == "options":
            for key, value in node.items():
                options[key] = value

        # Recurse the function over all sub-nodes of the current node
        for key, value in node.items():
            sub_node_options = extract_options(value, key)

            # Add all keys from sub-nodes into the parent node, raising an error in case of overwrite
            for sub_key, sub_value in sub_node_options.items():
                if sub_key in options:
                    raise ValueError(
                        "Duplicate definition for option %r in the same file.\nDefinition: %r\nNode name: %r"
                        % (sub_key, sub_value, node_name)
                    )
                else:
                    options[sub_key] = sub_value

    return options
