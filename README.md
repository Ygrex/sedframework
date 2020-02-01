# sedframework
Simple framework for programming on GNU sed.

Features:
* modular project structure,
* modules auto-loading by dependencies,
* trampoline based on a call stack,
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

## Contacts and License

Distributed under terms of BSD license, available in LICENSE file.

Author is @Ygrex <ygrex@ygrex.ru>.
