"""
GreenLight/greenlight/utils.py
Copyright (c) 2025 David Katzin, Wageningen Research Foundation
SPDX-License-Identifier: BSD-3-Clause-Clear
https://github.com/davkat1/GreenLight

Utilities functions for working with the greenlight package.

Public functions:
    copy_builtin_models(target_folder: str = "") -> None
        Copies the built-in model files that come in the greenlight package to a user-provided location.
        This allows users to create a local version of the files and manipulate or adjust them according to their needs.

Example usage:
    >>> from greenlight import copy_builtin_models
    >>> copy_builtin_models()
        Copies all built-in model files to the current working directory, in a sub-directory called "models"

External dependencies:
    - shutil for copying files
    - os and pathlib.Path for accessing system paths
    - importlib.resources for accessing the package resources
    - datetime.datetime for recording the time of copying
    - inspect for recording the name of the calling function

Author:
    David Katzin, Wageningen University & Research, david.katzin@wur.nl
September 2025
"""

import importlib
import importlib.resources as resources
import inspect
import os
import shutil
from datetime import datetime
from pathlib import Path


def copy_builtin_models(target_folder: str = "") -> None:
    """
    Copy the models included in the greenlight package (in the folder greenlight/models) to a user-specified location.
    When installing greenlight (e.g., using pip install), the built-in models are included as a package resource but
    should not be directly accessed or modified. Using this function allows to copy the model into a local folder
    where the user can manipulate the files in a local version and use those to run the model.
    The function also generates a readme file with the original file location, the time of copying, and a list of the
    copied files. This allows users to create new files while keeping track of what came from the package

    :param target_folder: Desired location of the copied files. Defaults to the current directory
    :return: None
    """
    if str == "":
        target_path = os.getcwd()

    target_path = Path(target_folder) / "models"
    target_path.mkdir(parents=True, exist_ok=True)

    models_origin = resources.files("greenlight").joinpath("models")

    def _copy_from_resource(src: Path, dst: Path, base_src: Path, copied_list: list) -> None:
        """
        Recursively go through src and copy it into dst, including sub-folders.
        Create a list of the copied files and their location relative to base_src

        :param src: Directory or file to copy. If it is a directory, the function will recurse into src's contents
        :param dst: Location of where src should be copied to
        :param base_src: Location of root source directory
        :param copied_list: Compiled list of copied files
        :return: None
        """
        if src.is_file():
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            # store relative path with POSIX separators for readability
            rel = src.relative_to(base_src).as_posix()
            copied_list.append(rel)
            return

        # src is a directory: make the directory and recurse through children
        dst.mkdir(parents=True, exist_ok=True)
        for child in src.iterdir():
            _copy_from_resource(child, dst / child.name, base_src, copied_list)

    # Copy files from the models folder to target_folder, iterating through sub-folders

    # Collect relative paths (strings) of all files copied
    copied_files: list[str] = []

    # Copy the files
    with resources.as_file(models_origin) as models_path:
        _copy_from_resource(Path(models_path), target_path, base_src=Path(models_path), copied_list=copied_files)

    # Create a readme file documenting the copy operation
    readme_path = target_path / "Readme.txt"

    # Capture the name of this function:
    frame = inspect.currentframe()
    try:
        this_function = frame.f_code.co_name
    finally:
        # remove local reference to frame to avoid reference cycles
        del frame

    readme_path.write_text(
        (
            f"The contents of this folder were copied from:\n{models_origin}\n"
            f"On: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
            f"Using the function: greenlight.{this_function}\n"
            f"GreenLight version: {importlib.metadata.version('greenlight')}\n"
            f"Copied files:\n {copied_files}"
        ),
        encoding="utf-8",
    )

    print(f"GreenLight built-in model files copied to {os.path.abspath(target_path)}")
