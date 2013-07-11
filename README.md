makefilePL-to-cpanfile
======================

Script to convert Makefile.PL files to cpanfile format

Currently only handles `requires` and `test_requires` directives.

SYNOPSIS
========

./makefilePL-to-cpanfile.pl /full/path/to/Makefile.PL > cpanfile

WHY?
====

I was using Makefile.PL to manage dependencies for an internal project, but
wanted to use `carton`.
