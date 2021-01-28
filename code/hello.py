#!/usr/bin/env python3
"""Simple module that defines a greetings function."""


def greetings(who="World"):
  """
  Function that prints a greetings message on the terminal.

  Parameters:
    who (str): the "person" to greet.
  """
  print(f"Hello, {who}!")


if __name__ == '__main__':
  import sys
  if len(sys.argv) > 1:
    greetings(sys.argv[1])
  else:
    greetings()
