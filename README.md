# sedframework
Simple framework for programming on GNU sed.

Features:
* modular project structure,
* modules auto-loading by dependencies,
* trampoline based on a call stack,
* unit testing,
* few functions for programming convenience:
  * debug and exception handling
  * pattern space snapshots saving/restoring

## Quick Start

Project structure:
```
sampleProject/
              main.sed
              runMe.sed      <- symlink to ./framework/runMe.sed
              input          <- created/overwritten in initialization
              trampoline.sed <- created/overwritten in initialization
              framework/
                        runMe.sed
                        ...
```
All scripts assume `sed -En` options (extended regular expressions with no
printing by default).

Project starts in `main.sed`, for example:
```
# Requires: trampoline.sed

b main

:sampleSub
	i sampleSub called.
	b trampoline

:main
	z ; s/^/stack:main_after_sampleSub,\n/ ; h
	b sampleSub
	:main_after_sampleSub
	i Got back to main.
	Q
```
Where `trampoline` loads from the framework:
```
$ ./runMe.sed <<<""
sampleSub called.
Got back to main.
```

## Unit Testing Quick Start

In order to demonstrate unit testing, there should be a testable unit.
Let's rewrite `main.sed` from the quick start example to have some function:
```
# Requires: trampoline.sed

b main

:uppercase
	s/^.*/\U&/
	b trampoline

:main
	x ; z; s/^/stack:main_after_uppercase,/ ; x
	b uppercase
	:main_after_uppercase
	p
	Q
```
Now it has a function to convert the input to upper case:
```
$ ./runMe.sed <<<"uppercase me please"
UPPERCASE ME PLEASE
```
There is a sample unit-test for it, put it as `unit-tests/main.sed`:
```
# Requires: main.sed

# put continuation to the call stack
z ; s/^/stack:here,/ ; h
# sample input
z ; s/^/text in lower case/
	# call the tested routine
	b uppercase
:here
	# make the output assumption
	s/^TEXT IN LOWER CASE$//
	t done
:uppercase_failure
	# enter an error following `err` convention
	s/^/uppercase: unit-tests failed!\n/
	# raise an exception
	b err
:done
	# Success report
	i Unit-tests PASSED!
	Q
```
Here `unit-tests/main.sed` is a special filename so that framework could
find the entry point. It is ready to run:
```
$ ./framework/runTests.sed <<<""
Unit-tests PASSED!
```

## Contacts and License

Distributed under terms of BSD license, available in LICENSE file.

Author is @Ygrex <ygrex@ygrex.ru>.
