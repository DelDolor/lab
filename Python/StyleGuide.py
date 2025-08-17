# This is my cheatsheat for Python notation #

# https://peps.python.org/pep-0008/
""" 
Spaces (4) are the preferred indentation method. 
Python disallows mixing tabs and spaces for indentation.

Modules should have short, all-lowercase names. Underscores can be used in the module name if it improves readability. 
Python packages should also have short, all-lowercase names, although the use of underscores is discouraged.    
Class names should normally use the CapWords convention
Function names should be lowercase, with words separated by underscores as necessary to improve readability.
Variable names follow the same convention as function names.
If a function argument’s name clashes with a reserved keyword: class_ 
Constants are usually defined on a module level and written in all capital letters with underscores separating words. 
    Examples include MAX_OVERFLOW and TOTAL

Limit all lines to a maximum of 79 characters:
123456789022345678903234567890423456789052345678906234567890723456789
Limiting the required editor window width makes it possible to have 
several files open side by side, and works well when using 
code review tools that present the two versions in adjacent columns.

Surround top-level function and class definitions with two blank lines.
Method definitions inside a class are surrounded by a single blank line.

Module level “dunders” such as __all__, __author__, __version__, etc. 
should be placed after the module docstring but before any import 
statements except from __future__ imports. Python mandates that 
future-imports must appear in the module before any other code except docstrings:
    
_single_leading_underscore: weak “internal use” indicator.
single_trailing_underscore_: used by convention to avoid conflicts with Python keyword
__double_leading_underscore: when naming a class attribute, invokes name mangling (inside class FooBar, __boo becomes _FooBar__boo; see below).
__double_leading_and_trailing_underscore__: “magic” objects or attributes that live in user-controlled namespaces. E.g. __init__, __import__ or __file__. 
    Never invent such names; only use them as documented.
 

"""

####### some samples ##########

"""This is the example module.

This module does stuff.
"""

from __future__ import barry_as_FLUFL

__all__ = ['a', 'b', 'c']
__version__ = '0.1'
__author__ = 'Cardinal Biggles'

import os
import sys
import mypkg.sibling #use this when possible
from mypkg import sibling
from . import sibling
from .sibling import example

# Hanging indents should add a level.
foo = long_function_name(
    var_one, var_two,
    var_three, var_four)

# Two character keyword (i.e. if), plus a single space, 
# plus an opening parenthesis creates a natural 4-space indent for 
# the subsequent lines of the multiline conditional.
# No extra indentation.
if (this_is_one_thing and 
    that_is_another_thing):
    # Comment what happens
    do_something()

# closing brace/bracket/parenthesis on multiline constructs 
my_list = [
    1, 2, 3,
    4, 5, 6,
]
result = some_function_that_takes_arguments(
    'a', 'b', 'c',
    'd', 'e', 'f',
)

# operators
# easy to match operators with operands
income = (gross_wages
          + taxable_interest
          + (dividends - qualified_dividends)
          - ira_deduction
          - student_loan_interest)

# Correct:
ham[1:9], ham[1:9:3], ham[:9:3], ham[1::3], ham[1:9:]
ham[lower:upper], ham[lower:upper:], ham[lower::step]
ham[lower+offset : upper+offset]
ham[: upper_fn(x) : step_fn(x)], ham[:: step_fn(x)]
ham[lower + offset : upper + offset]

# Wrong:
ham[lower + offset:upper + offset]
ham[1: 9], ham[1 :9], ham[1:9 :3]
ham[lower : : step]
ham[ : upper]

# Correct:
x = 1
y = 2
long_variable = 3

# Wrong:
x             = 1
y             = 2
long_variable = 3