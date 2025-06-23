"""
GreenLight/greenlight/_load/_expand_functions.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Functions for parsing model function calls and definitions in a GreenLightInternal object.

Public functions:
    parse(expressions_to_format: dict[str, str], functions: dict[str, str], builtin_expressions: Iterable[str]) -> None
        Modify expressions_to_format so that all function calls in this dict are expanded to their full description.
        Example: if "func1(x, y + z)" appears in expressions_to_format and functions["func1(a, b)"] is "a + b**2", then
         "func1(x, y + z)" will be replaced by "x + (y + z)**2".

Example usage:
    >>> _expand_functions.parse(mdl.variables, mdl.functions, builtin_expressions)
    where:
        `mdl.variables` are the variables of a GreenLightInternal object (loaded using greenlight._load.load_model)
        `mdl.functions` are the functions of a GreenLightInternal object (loaded using greenlight._load.load_model)
        `builtin_expressions` is a list of builtin expressions (e.g., ["sin", "exp"])

Exceptions:
    ValueError in case of mismatched parentheses, mismatch in number of parameters between a function call and its
        definition, a function definition is not found, or anything else went wrong during substitution.

External dependencies:
    - None
"""

import logging
import re
from typing import Iterable


def parse(expressions_to_format: dict[str, str], functions: dict[str, str], builtin_expressions: Iterable[str]) -> None:
    """
    Modify the dict expressions_to_format so that all function calls in this dict are expanded to their full
    description. Builtin expressions are ignored.
    In expressions_to_format, any function call will be replaced by its expansion based on functions.
    Example: if expressions_to_format is {"var1": "func1(x, y + z)"} and f_defs is {"func1(a, b)": "a + b**2"},
    expressions_to_format will be modified to {"var1": "x + (y + z)**2"}.
    This parsing helps convert model definitions in a given model used into fully expanded expressions which may be
    used by multiple solvers, enhancing flexibility and running speed.

    :param expressions_to_format: A dict containing variables and their mathematical definitions, which may include
        function calls. Example: {"var1": "func1(x, y + z), "var2": "var1 + 5"}
    :param functions: A dict of function declarations and descriptions. Example: {"func1(a, b)": "a + b**2"}
    :param builtin_expressions: Expressions that do not need to parsed as a function. Example: ["exp", "sqrt"]
    """
    func_pattern = r"(\w+)\((.*?)\)"  # A word, '(', some words, ')'

    function_args = {}  # A dictionary with function names and arguments
    function_defs = {}  # A dictionary with function names and definitions

    # Go through all functions and collect definitions and arguments
    for key, value in functions.items():
        match = re.match(func_pattern, key)
        if match:
            func_name = match.group(1)
            function_args[func_name] = re.split(r"\s*,\s*", match.group(2))
            function_defs[func_name] = value

    # Functions do not need to be formatted
    for key, value in functions.items():
        del expressions_to_format[key]

    for key, value in expressions_to_format.items():
        expressions_to_format[key] = _parse_expression(value, function_defs, function_args, builtin_expressions)


def _parse_expression(
    expr: str, f_defs: dict[str, str], f_args: dict[str, Iterable[str]], builtin: Iterable[str]
) -> str:
    """
    Given a string expr and dicts of function definitions and arguments, replace any appearance of a function in expr
    with the full definition of the function. Ignore any builtin expressions.
    Example: if expr is "func1(x, y + z)", f_defs is {"func1": "a + b**2"}, and f_args is {"func1": ["a", "b"]}
    The function will return "x + (y + z)**2".
    This function recurses through all function calls in expr to ensure that all function calls are replaced
    :param expr: A string with a mathematical expression which may include some function calls, e.g., "func1(x, y + z)".
    :param f_defs: A dict with function definitions, e.g., {"func1": "a + b**2"}
    :param f_args: A dict with function arguments. The keys in f_args should be the same as the keys of f_defs.
        Both should include all function names in str
    :param builtin: An Iterable[str] with function names that need not be parsed, e.g., ["exp", "sqrt"]
    :return: A parsed string where the function calls in expr are replaced by the function definition,
        e.g., "x + (y + z)**2"
    :raises: ValueError if a function call func1() is found but its definition doesn't exist in f_defs.
             ValueError if a function call func1() is found but the number of arguments doesn't match the number of
                arguments in f_args.
             ValueError if for any other reason the substitution fails.
    """
    # Get a list of the highest-level functions in expr
    high_level_funcs = _high_level_functions(expr)

    # If expr contains multiple high-level functions, parse them individually
    if len(high_level_funcs) > 1:
        parsed_high_level_funcs = [_parse_expression(func, f_defs, f_args, builtin) for func in high_level_funcs]

        parsed_func_call = expr
        # replace the parsed funcs in expr
        for i, arg in enumerate(high_level_funcs):
            parsed_func_call = re.sub(re.escape(arg), parsed_high_level_funcs[i], parsed_func_call)

        return parsed_func_call

    # Check if expr contains any relevant function call
    greedy_func_pattern = r"(\w+)\((.*)\)"
    func_call = re.search(greedy_func_pattern, expr.strip())
    if not func_call or expr in builtin:
        return expr  # No relevant function call, return as is

    # Otherwise, expr contains one high-level function. Start by handling the outermost level
    outermost_func = _outermost_function(expr)
    if not outermost_func:
        return expr  # No function call found, return as is

    func_call = outermost_func[0]  # Full function call
    func_name = outermost_func[1]  # Function name
    call_args = outermost_func[2:]  # Function arguments

    # Example: if outermost_func is "func1(x, y + z)",
    # then func_call is "func1(x, y + z)", func_name is "func1", call_args is ["x", "y + z"]

    if func_name not in f_defs.keys() | builtin:
        raise ValueError("No definition found for function %r" % (func_name,))

    if func_name in builtin:  # builtin function, only the arguments may need to be parsed
        parsed_func_call = func_call
    else:  # parse the function call
        parsed_func_call = f_defs[func_name]
        func_args = f_args[func_name]

        # Example: if f_defs["func1"] is "a + b**2" and f_args["func1"] is ["a", "b"],
        # then parsed_func_call is "a + b**2" and func_args is ["a", "b"]
        # Now, just need to modify parsed_func_call: replace "a" with "x" and "b" with "y + z"

        # First check that the number of func_args and call_args is the same
        if len(func_args) != len(call_args):
            raise ValueError(
                "Error in function %r while replacing %r with %r: mismatch in number of arguments"
                % (func_name, call_args, func_args)
            )
        # If so, replace the function args (func_args) with the call args (call_args)
        try:
            logger = logging.getLogger(__name__)
            for i, arg in enumerate(call_args):
                parsed_func_call = re.sub(r"\b%s\b" % func_args[i], f"({arg})", parsed_func_call)
        except Exception:
            logger.error("Error in function %r while replacing %r with %r" % (func_name, call_args, func_args))
            raise ValueError

    # Now also parse the function call arguments if needed
    for call_arg in call_args:
        parsed_call_arg = _parse_expression(call_arg, f_defs, f_args, builtin)
        parsed_func_call = re.sub(re.escape(call_arg), parsed_call_arg, parsed_func_call)

    return re.sub(re.escape(func_call), f"({parsed_func_call})", expr)


def _high_level_functions(input_str: str) -> list[str]:
    """
    Given an input string containing a mathematical expression, list the names of the highest-level functions described
    in the string.
    :param input_str: A mathematical expression possibly containing multiple, nested, function calls,
        e.g., "func1(a + b * c * func2(func3(x)) + func4(b, c), b + d) + func5(y)"
    :return: The names of the highest-level functions of input_str, e.g., ["func1", "func5"]
    :raises: ValueError if mismatched parentheses are found.
    """
    funcs = []
    current_func = []
    depth = 0

    # Regular expression to match any non-alphanumeric character except whitespace
    non_alnum_pattern = re.compile(r"[^a-zA-Z0-9_\s]")

    for char in input_str:
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth < 0:
                raise ValueError("Mismatched parentheses in string %r" % (input_str,))
        elif non_alnum_pattern.match(char) and depth == 0:
            # Split at operator only if it's at the top level (depth == 0)
            funcs.append("".join(current_func).strip())
            current_func = []
            continue

        current_func.append(char)

    if depth != 0:
        raise ValueError("Mismatched parentheses in string %r" % (input_str,))

    # Add the last collected function call to funcs
    if current_func:
        funcs.append("".join(current_func).strip())

    return funcs


def _outermost_function(input_str: str) -> list[str]:
    """
    Given an input string containing a mathematical expression, find the outermost (highest level) function described
    in the string.
    :param input_str: A mathematical expression possibly containing multiple, nested, function calls,
        e.g., "func1(a + b * c * func2(func3(x)) + func4(b, c), b + d)"
    :return: The outermost function in input_str, in the following order:
        - The full function call, e.g., "func1(a + b * c * func2(func3(x)) + func4(b, c), b + d)"
        - The function name, e.g., "func1"
        - All other function arguments, e.g., ["a + b * c * func2(func3(x)) + func4(b, c)", "b + d"]
    """
    # Remove leading and trailing white spaces and parentheses if they exist
    func_call = input_str.strip()
    while func_call.startswith("(") and func_call.endswith(")"):  # Check for outer parentheses
        func_call = func_call[1:-1].strip()  # Remove outer parentheses if present

    # Regular expression to match the function name at the start of the string
    func_name_pattern = re.compile(r"\b(\w+)\s*\(")
    matches = func_name_pattern.finditer(func_call)

    if not matches:
        return []

    # Extract the function name
    match = next(matches, None)
    func_name = match.group(1)

    # Initialize variables for extracting arguments
    start_idx = match.end()  # Position after the opening parenthesis
    end_idx = len(func_call)
    depth = 0
    current_arg = []
    args = []

    # Iterate over the string to extract arguments
    for i in range(start_idx, len(func_call)):
        char = func_call[i]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1

        # When depth is 0 and we encounter a comma, it means we've reached the end of an argument
        if char == "," and depth == 0:
            args.append("".join(current_arg).strip())
            current_arg = []
        else:
            current_arg.append(char)

        # When we reach the closing parenthesis at the top depth, finish parsing
        if depth < 0 and char == ")":
            end_idx = i
            current_arg = current_arg[:-1]
            break

    # Add the last argument, if any
    if current_arg:
        args.append("".join(current_arg).strip())

    # Return the function call - do not include any strings that were outside the call
    match = re.search(r"\b\w+\($", func_call[:start_idx])
    if match:
        func_call = match.group(0) + func_call[start_idx : end_idx + 1]

    return [func_call, func_name] + args
