@echo off

:: Create a conda environment
call conda create -y --name greenlight python=3.10

:: Activate the conda environment
source activate greenlight


:: Install packages from requirements_dev.txt and requirements.txt
pip install -r requirements_dev.txt
pip install -r requirements.txt
pip install -e .

:: Install pre-commit hooks to check validity of code changes
pre-commit install
