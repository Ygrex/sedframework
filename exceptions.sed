#!/bin/sed -Enf

# Requires: trampoline.sed

# Module distributed with sedframework.

# {{{ err: show an error message, dump state and halt program
:err
	s/^/EE: Halt on Exception!\n/
	W /dev/stderr
	s/^[^\n]*\n/EE: /
	W /dev/stderr
	s/^[^\n]*\n/\n>>> Pattern:\n/
	s/$/\n<<<\n/
	w /dev/stderr
	g
	s/^/\n>>> Hold:\n/
	s/$/\n<<<\n/
	w /dev/stderr
	z
	s/^/EC:1/
	w /dev/fd/3
	Q1
# }}}

# {{{ debug: dump state
# Data is not changed.
:debug
	s/^/>>> DEBUG: Pattern:\n/
	s/$/\n<<< DEBUG\n/
	w /dev/stderr
	s/\n<<< DEBUG\n$//
	s/^>>> DEBUG: Pattern:\n//
	x
	s/^/>>> DEBUG: Hold:\n/
	s/$/\n<<< DEBUG\n/
	w /dev/stderr
	s/\n<<< DEBUG\n$//
	s/^>>> DEBUG: Hold:\n//
	x
	b trampoline
# }}}

# vim: foldmethod=marker
