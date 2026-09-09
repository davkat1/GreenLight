# GreenLight
A Python platform for creating, modifying, and combining dynamic models, with a focus on horticultural greenhouses and crops.

## Quick start
```shell
pip install greenlight
python -m greenlight.main
```

or:
```shell
pip install greenlight
import greenlight
mdl = greenlight.GreenLight()
mdl.run()
```

## Documentation
See [Read the Docs](https://greenlight.readthedocs.io).

## Announcements
### Change in default branch name
As of version `2.0.2`, the default branch name has changed from `master` to `main`.
If you have a local clone, you can update it by running the following commands:

```shell
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
```

### Previous versions
Versions 1.x of this repository are programmed in MATLAB, and their development is discontinued.
Looking for the last MATLAB version of GreenLight? You can find it [here](https://github.com/davkat1/GreenLight/tree/4ec6018e0aad2775ad11085d34f3886a7b7dd052).

### Active discussions on Discord
Users are welcome to join the [GreenLight Discord server](https://discord.gg/MwExawsgQc) to post their questions, wishes, ideas - and hopefully help each other.

## License
This project is licensed under the [BSD 3-Clause-Clear License](https://choosealicense.com/licenses/bsd-3-clause-clear/). See the [LICENSE](LICENSE.txt) file for details.

## Repository structure
- `docs` contains detailed documentation on how to work with the repository
- `greenlight` holds the Python module containing the platform implementations
- `greenlight/models` contains files that define models implemented on the platform
- `notebooks` contain example notebooks that use the python module in this package
- `scripts` contains Python scripts and examples that use this package

## Contributors
- David Katzin, Wageningen University & Research, david.katzin@wur.nl
- Pierre-Olivier Schwarz, Université Laval
- Joshi Graf, Wageningen University & Research
- Cristina Zepeda, Wageningen University & Research
- Stef Maree, Wageningen University & Research
- User [shanakaprageeth](https://github.com/shanakaprageeth) on [github.com](https://github.com)

## Acknowledgements
Thank you to [Ian McCracken](https://github.com/iancmcc) for providing the [PyPI GreenLight namespace](https://pypi.org/project/GreenLight/)


*This package was created with [Cookiecutter](https://github.com/audreyr/cookiecutter) and the [WUR Greenhouse Technology cookiecutter](https://git.wur.nl/glas/pyproject) project template.*
