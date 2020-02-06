#!/bin/sed -uEnf

# Module distributed with sedframework.

# runMe.sed is the CLI entry-point. It initializes framework and continues
# to the project's main.sed.
#
# The intended way of usage is to:
# - the project's execution path starts in main.sed
# - sedframework is available in framework/ directory
# - runMe.sed in the top-level directory simlinks to framework/runMe.sed

b runMe

# {{{ runMyTests: runs main.sed from 'unit-tests' directory
:runMyTests
	z
	s|^|sed -Ene 'b generateTrampoline_listTestFiles' -f ./framework/generateTrampoline.sed -- ./framework/generateTrampoline.sed|
	b runMe_after_generateTrampoline
# }}}

# {{{ runMe: CLI entry point, framework launcher
:runMe
	W input
	z
	s|^|sed -Enf ./framework/generateTrampoline.sed -- ./framework/generateTrampoline.sed|
	:runMe_after_generateTrampoline
	e
	# load each script with -f option
	s/^/-f /mg
	# quit after the first module
	s|$| -e 'z ; s/^/EC:2/ ; w /dev/fd/3' -e Q2 |m
	# command and generic options
	s/^/sed -En /
	# input and redirection, fd=3 is for feeback pipe
	s,$, -- ./input /dev/stdin 3>\&1 >/dev/tty,
	# glue lines into one command
	s/\n/ /g
	# Example command:
	# sed -uEn -f main.sed -e Q2 -f a.sed -f b.sed -- ./input /dev/stdin >/dev/tty
	e
	W input
	/^EC:1$/ Q1
	/^EC:2$/ Q2
	Q
# }}}

# vim: foldmethod=marker
