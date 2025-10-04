# GreenLight Unit Tests

This directory contains unit tests for the GreenLight greenhouse modeling platform.

## Running Tests

### Using the test runner script:
```bash
python unittests/run_tests.py
```

### Using Python's unittest module:
```bash
python -m unittest discover unittests -v
```

### Using pytest (if installed):
```bash
pytest unittests/
```

## Test Structure

- `test_core.py` - Tests for core GreenLight functionality
- `test_energy_plus.py` - Tests for EnergyPlus weather data conversion
- `test_utils.py` - Tests for utility functions
- `run_tests.py` - Test runner script

## Test Coverage

The tests cover:
- Basic package imports and functionality
- GreenLight instance creation
- Model copying utilities
- EnergyPlus conversion function signatures
- Error handling for missing files

## Adding New Tests

When adding new tests:
1. Create test files with the `test_*.py` naming pattern
2. Inherit from `unittest.TestCase`
3. Use descriptive test method names starting with `test_`
4. Include docstrings explaining what each test does
5. Clean up any temporary files in `tearDown()` methods