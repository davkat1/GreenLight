#!/usr/bin/env python

"""The setup script."""

from setuptools import find_packages, setup

with open("README.md") as readme_file:
    readme = readme_file.read()

requirements = ["numpy", "numexpr", "scipy", "pandas", "matplotlib", "tkcalendar"]

setup_requirements = []

test_requirements = []

setup(
    author="David Katzin",
    author_email="david.katzin@wur.nl",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Natural Language :: English",
        "Programming Language :: Python :: 3.10",
        "License :: OSI Approved :: BSD License",
    ],
    license="BSD-3-Clause-Clear",
    description="A platform for creating, modifying, and combining dynamic models, with a focus on horticultural greenhouses and crops",
    install_requires=requirements,
    long_description=readme,
    include_package_data=True,
    keywords="greenlight",
    name="greenlight",
    packages=find_packages(
        include=["greenlight", "greenlight.*"]
    ),
    setup_requires=setup_requirements,
    url="https://github.com/davkat1/GreenLight",
    version="2.0.3",
    zip_safe=False,
)
