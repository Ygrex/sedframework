#!/bin/sed -uEnf

# Module distributed with sedframework.

b runTests

# {{{ runTests: unit-tests launcher
:runTests
	z
	s/^/sed -uEne 'b runMyTests' -f runMe.sed -- runMe.sed/e
	s/^/sed -e '' -- input/e
	/^EC:1$/ Q1
	/^EC:2$/ Q2
	Q
# }}}

# vim: foldmethod=marker
