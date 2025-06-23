"""
GreenLight/greenlight._load._utils.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Functions for performing tasks related to loading a GreenLightInternal object

Functions:
    - flatten_input(input_prompt: str | dict | list[str | dict]) -> list[str | dict]
        Recursively convert input_prompt to a flattened list containing only dicts and strings
    - is_replacement(mdl, new_variables, key, update_type) -> bool
        Determine if an update to a GreenLightInternal variable is considered a replacement
    - is_update_to_perform(mdl, new_variables, key, update_type) -> bool
        Determine if an update to a GreenLightInternal variable should be performed
    - json_raise_on_duplicates(ordered_pairs: list[tuple[Any, Any]]) -> dict
        object_pairs_hook function for using in json._load. Raises an error if the loaded JSON file contains
        a duplicate key
    - expressions_to_dy_str(
        y_vars: dict[str, str], d_vars: Iterable[str], a_vars: dict[str, str] = [], a_order: Iterable[str] = []
        ) -> list[str]
        Create a list of Python type expressions from variable definitions
    - find_dependencies(expression: str, variables: Iterable[str], ignore: Iterable[str]) -> set
        Find all variables that a given variable depends on
    - check_for_cycles(expressions: Iterable[str], dependencies: dict, basis_expressions: Iterable[str]) -> None
        Given variable expressions and their dependencies, check if there are any circular dependencies
"""

import re
from typing import Any, Iterable


def flatten_input(input_prompt: str | dict | list[str | dict]) -> list[str | dict]:
    """
    Recursively convert input_prompt to a flattened list containing only dicts and strings

    :param input_prompt: A string, dict, or a list containing strings, dicts, and lists of strings and dicts, etc.
    :return: A flattened list containing only strings and dicts extracted from input_prompt
    """
    flattened = []

    if input_prompt:
        if isinstance(input_prompt, str):
            flattened.append(input_prompt)
        elif isinstance(input_prompt, dict):
            flattened.append(input_prompt)
        elif isinstance(input_prompt, list):
            for item in input_prompt:
                flattened.extend(flatten_input(item))

    return flattened


def is_replacement(mdl, new_variables, key, update_type) -> bool:
    """
    Before updating a variable definition, unit, description, or reference, determine if the update
    is considered a replacement. An update is considered a replacement if the following hold:
        1. The new key already exists in mdl
        2. The new value is different from the old value
        3. The new value is not some default value:
            - For variable definitions, this holds if key == value
            - For units, the default is "no_unit_defined"
            - For descriptions, the default is ""
            - For references, the default is ""
    :param mdl: A GreenLightInternal object to be updated
    :param new_variables: A dict of new variables, created by _parse_model.extract_variables()
    :param key: Name of the new variable
    :param update_type: "definition", "unit", "description", or "reference"
    :return: True if updating with the provided values is considered a replacement
    """
    if update_type == "definition":
        return (
            key in mdl.variables
            and mdl.variables[key] != new_variables["definition"][key]
            and key != new_variables["definition"][key]
        )
    elif update_type == "unit":
        return (
            key in mdl.var_units
            and mdl.var_units[key] != new_variables["unit"][key]
            and new_variables["unit"][key] != "no_unit_defined"
        )
    elif update_type == "description":
        return (
            key in mdl.var_descriptions
            and mdl.var_descriptions[key] != new_variables[update_type][key]
            and new_variables[update_type][key]
        )
    elif update_type == "reference":
        return (
            key in mdl.var_refs
            and mdl.var_refs[key] != new_variables["reference"][key]
            and new_variables["reference"][key]
        )

    else:
        return False


def is_update_to_perform(mdl, new_variables, key, update_type) -> bool:
    """
    Before updating a variable definition, unit, description, or reference, determine if the update
    should be performed. This is true if one the following hold:
        - The new key doesn't exist yet in mdl
        OR
        - The new key does already exist in mdl, AND the new value is NOT a default value

    :param mdl: A GreenLightInternal object to be updated
    :param new_variables: A dict of new variables, created by _parse_model.extract_variables()
    :param key: Name of the new variable
    :param update_type: "definition", "unit", "description", or "reference"
    :return: True if the update needs to be performed
    """
    if update_type == "definition":
        return key not in mdl.variables or key != new_variables["definition"][key]
    elif update_type == "unit":
        return key not in mdl.var_units or new_variables["unit"][key] != "no_unit_defined"
    elif update_type == "description":
        return key not in mdl.var_descriptions or new_variables["description"][key]
    elif update_type == "reference":
        return key in mdl.var_refs or new_variables["reference"][key]
    else:
        return False


def json_raise_on_duplicates(ordered_pairs: list[tuple[Any, Any]]) -> dict:
    """
    object_pairs_hook function for json._load
    Using this function as an object_pairs_hook in json._load causes an error to be raised if the loaded JSON file
    contains duplicate keys.
    Thanks to user jfs on stackoverflow, https://stackoverflow.com/a/14902564
    :param ordered_pairs: A key and a value from the JSON file
    :return: dict, same as typically returned by json._load
    :raises: ValueError if a duplicate key is found
    """
    d = {}
    for k, v in ordered_pairs:
        if k in d:
            raise ValueError(
                "Duplicate key: %r with value: %r"
                % (
                    k,
                    v,
                )
            )
        else:
            d[k] = v
    return d


def expressions_to_dy_str(
    y_vars: dict[str, str], d_vars: Iterable[str], a_vars: dict[str, str] = [], a_order: Iterable[str] = []
) -> list[str]:
    """
    Given a dict of expressions and a list of variable names, create a list of expressions starting with "dy[...]=",
    where the variable names in y_expressions are expressed as elements of an array y, and the variable names of d_vars
    are expressed as elements of array d.
    This function is meant to be used when y_expressions describe differential equations (dy) of states (y),
    and these equations may include some inputs (d) or auxiliary states (a).
    The newly created array can be used to define functions that can then be used by ODE solvers.

    Example:
        if y_expressions = {"var1": "a_var1 + input1", "var2": "input2+5"}
        d_vars = ["input1", "input2"],
        a_vars = {"a_var1": "var1 + var2"}
    the function will return:
        ["a[0] = y[0] + y[1]",
        "dy[0]=a[0]+d[0]",
        "dy[1]=d[1]+5"]
    :param a_vars: A dict containing auxiliary variables, with their names as keys and their definitions as values
    :param a_order: An Iterable[str] of the keys in a_vars, sorted so that the variables can be resolved
        in the given order.
        For example, if a_vars = {"a_var1": "a_var2 + 3", "a_var2": "6"},
        then a_var1 depends on a_var2,
        therefore a_var2 should appear before a_var1 in a_order.
    :param y_vars: A dict containing state variable, with their names as keys and definitions as values.
    :param d_vars: An Iterable[str] containing names of variables, for example model input variables.
    :return: array_expressions: A list[str] of reformatted expressions as described above.
    """
    array_expressions = []
    if type(a_vars) is dict:
        a_vars_keys = a_vars.keys()
    else:
        a_vars_keys = []
    for i, (var_name) in enumerate(a_order):
        array_expressions.append("a[" + str(i) + "] = " + a_vars[var_name])
        for j, (y_var_name) in enumerate(y_vars.keys()):
            array_expressions[-1] = re.sub(r"\b%s\b" % y_var_name, "y[" + str(j) + "]", array_expressions[-1])
        for j, (a_var_name) in enumerate(a_vars.keys()):
            array_expressions[-1] = re.sub(r"\b%s\b" % a_var_name, "a[" + str(j) + "]", array_expressions[-1])
        for j, (d_var_name) in enumerate(d_vars):
            array_expressions[-1] = re.sub(r"\b%s\b" % d_var_name, "d[" + str(j + 1) + "]", array_expressions[-1])
    for i, (var_name, expression) in enumerate(y_vars.items()):
        array_expressions.append("dy[" + str(i) + "] = " + expression)
        for j, (y_var_name) in enumerate(y_vars.keys()):
            array_expressions[-1] = re.sub(r"\b%s\b" % y_var_name, "y[" + str(j) + "]", array_expressions[-1])
        for j, (a_var_name) in enumerate(a_vars_keys):
            array_expressions[-1] = re.sub(r"\b%s\b" % a_var_name, "a[" + str(j) + "]", array_expressions[-1])
        for j, (d_var_name) in enumerate(d_vars):
            array_expressions[-1] = re.sub(r"\b%s\b" % d_var_name, "d[" + str(j + 1) + "]", array_expressions[-1])

    return array_expressions


def find_dependencies(expression: str, variables: Iterable[str], ignore: Iterable[str]) -> set:
    """
    Given a variable definition expression, this function allows to find all variables that the given variable
    depends on, in other words, the variables dependencies. The functions returns the set of variable names from
    variables that are mentioned in expression. Names that are in ignore are excluded.
    :param expression: str containing some mathematical expression, including some variable names.
    :param variables: An Iterable[str] of variable names. A name included in variables is considered a dependency.
    :param ignore: An Iterable[str] of variable names that do not count as dependencies (for example, built-in variables
        or expressions like exp, sqrt)
    :return: A set of all dependencies (a subset of vars) listed in expression
    """
    pattern = r"\b(?:{})\b".format("|".join(re.escape(var_name) for var_name in variables))

    dependencies = set(re.findall(pattern, expression))
    for var_name in ignore:
        if var_name in dependencies:
            dependencies.remove(var_name)

    return dependencies


def check_for_cycles(expressions: Iterable[str], dependencies: dict, basis_expressions: Iterable[str]) -> None:
    """
    Given variable expressions and their dependencies, check if there are any circular dependencies
    (i.e., a depends on b which depends on a).
    :param expressions: An Iterable[str] of expression names, which are a subset of dependencies.keys().
    :param dependencies: A dict of dependencies: dependencies[key] is a set containing the names of all variables
        that key depends on. This dict can be created with _find_dependencies.
    :param basis_expressions: Expressions that are not considered to be a dependency. The function will not check for
        circular dependencies which include these expressions.
    :return: None
    :raises: A ValueError if a circular dependency is found
    """
    visited = set()
    stack = set()

    def _visit(exp, path):
        if exp in stack:
            raise ValueError(f"Circular dependency detected involving {exp}: {' -> '.join(path + [exp])}")
        if exp not in visited:
            stack.add(exp)
            visited.add(exp)
            path.append(exp)
            for dep in dependencies[exp]:
                if dep not in basis_expressions:
                    _visit(dep, path)
            path.pop()
            stack.remove(exp)

    for expr in expressions:
        _visit(expr, [])
