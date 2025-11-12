#!/usr/bin/env python3
"""
Test runner for GreenLight unit tests.

This script discovers and runs all unit tests in the unittests directory.
"""

import os
import sys
import unittest

# Add the parent directory to the path so we can import greenlight
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def run_tests():
    """Discover and run all unit tests."""
    # Get the directory containing this script
    test_dir = os.path.dirname(os.path.abspath(__file__))

    # Discover tests
    loader = unittest.TestLoader()
    start_dir = test_dir
    suite = loader.discover(start_dir, pattern='test_*.py')

    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    # Return appropriate exit code
    return 0 if result.wasSuccessful() else 1


if __name__ == '__main__':
    sys.exit(run_tests())
