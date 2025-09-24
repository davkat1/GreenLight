# Installation and usage instructions
This repository contains the `greeenlight` package. Here we describe how to install it.

In this file:
- [General installation guide](#general-installation-guide)
- [Installing this repository](#installing-this-repository)
- [Copying built-in models](#copying-built-in-models)
- [Developer installation](#developer-installation)
  - [Non-conda users](#non-conda-users)
- [Pre-commit](#pre-commit)
- [Jupyter Notebooks](#jupyter-notebooks)

## General installation guide
For use of GreenLight in other Python projects, simply install as any other package:

```shell
pip install greenlight
```
or:
```shell
conda install greenlight
```

To ensure that you are installing the latest GreenLight version, make sure `pip` is not installing from cache:
```shell
pip install --no-cache-dir greenlight
```


## Installing this repository
Alternatively, you may choose to install this entire repository, which includes,
besides the `greenlight` package, some scripts and examples. For this:

1. Download the entirety of the [GreenLight repository](https://github.com/davkat1/GreenLight) either by clicking the
**Code** button and selecting **Download ZIP** or by cloning the git repository
2. Open the project folder in your favourite Python IDE or other editor
3. Set up a new Python environment (current recommended version is 3.10). <br>If you are using `conda`, you may do it like so:
```shell
call conda create -y --name greenlight python=3.10
source activate greenlight
```
4. Install the required packages:
```shell
pip install -r requirements.txt
```
5. Install the local `greenlight` package in editable mode:
```shell
pip install -e .
```

5. a. Depending on your setup, you may need to go up one directory from the project directory in order to install the local `greenlight` package:
```shell
cd ..
pip install -e ./greenlight
cd greenlight
```

6. If you intend to develop code, run the additional:
```shell
pip install -r requirements_dev.txt
pre-commit install
```

## Copying built-in models
If you want to adjust or extend model, copy the builtin models to a local directory, e.g.:
```python
import greenlight
greenlight.copy_builtin_models(r"C:\builtin_models")
```

## Developer installation
For `conda` users on Windows, the script
```shell
./init_python_env_windows.bat
```
can be called to set up a python environment and install the requirements. On unix systems, use the equivalent `init_python_env.sh`.

### Non-conda users
For non-conda or non-windows users, have a look at the `init_python_env_windows.bat` script to set up your environment manually.
Basically, it is the same as the instructions above: creating a python environment, that we name `greenlight` and has Python version `3.10`, in which you install the requirements and package itself.

## Pre-commit
Pre-commit performs code integrity checks and style checks before committing. Note that you do need the `git` command line for that. Based on your project, you can choose to add/change the pre-commit hooks.

## Jupyter Notebooks
Jupyter notebooks (`*.ipynb`) are difficult to version control as they are not plain text. At the same time, they interface nicely with github to allow easily demonstrating the repository's capabilities.
Therefore, the Python module `jupytext` is used to create a script out of notebooks. If you install the development requirements
before starting jupyter, you can just open them like any other notebook. It then synchronizes the `*.ipynb` with a `*.py`
file of the same name, and you can commit the `*.py` version. The `*.py` version are easier to version control and can be used for helping with merge requests, etc.

Tip: When you develop a package locally, you need to reload the imported packages every time in your notebook.
To automate that, add the following snippet to the first cell of your notebooks:
```python
%load_ext autoreload
%autoreload 2
```
