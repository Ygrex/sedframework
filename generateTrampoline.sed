#!/bin/sed -Enf

# Module distributed with sedframework.

# Module is called indirectly from runMe.sed during initialization.
# It creates trampoline.sed module in the top-level project directory,
# which provides a call stack dispatcher for all labels found in the project.

# Read labels from supported files, generate a trampoline subroutine
# for all detected labels, dump the whole trampoline subroutine to a
# file trampoline.sed.
# The file gets created if does not exists, overwritten otherwise.
# Resulting file located in the current working directory.

# {{{ generateTrampoline_listFiles: list of scripts to load
# Start with main.sed, read out its requirements, expand each one the same way.
:generateTrampoline_listFiles
	z
	s,^,main.sed\nframework/exceptions.sed\n=\n,
	b generateTrampoline_expandRequirements
# }}}

# {{{ generateTrampoline_expandRequirements: expand requirements
# Given a '=' terminated list of script file names, read out
# requirements from them.
:generateTrampoline_expandRequirements
	t generateTrampoline_expandRequirements
	# marker is on the top - stop condition
	s/^=\n//
	t generateTrampoline_allExpanded
	# shift the expanding file after the marker
	s/^([^\n]+\n)(.*=\n)/\2\1/
	# save that in hold space for later re-use
	h
	# remove everything but a name of the expanding file
	s/^.*=\n([^\n]+).*$/\1/
	s|^|sed -Ene '/^#\\s*Requires:/ {p;q} ; 5q' -- |
	e
	y/,/ /
	s/^#\s*Requires:\s*//
	s/\s*$/ /
	s/\s\s*/\n/g
	s/^/-\n/
	H
	g
	s/^\n+//mg
	b generateTrampoline_mergeRequirements
	p;Q
# }}}

# {{{ generateTrampoline_mergeRequirements: merge new requirements
# There are three lists of files:
#
# <to be expanded>
# =
# <expanded>
# -
# <to be merged>
#
# Here <to be merged> should be included to the top of
# <to be expanded> but only those rows, which are not yet
# mentioned in <to be expanded> or <expanded>.
:generateTrampoline_mergeRequirements
	t generateTrampoline_mergeRequirements
	# Test if <to be merged> is empty:
	s/^(.*)-\n+$/\1/
	t generateTrampoline_expandRequirements
	# Put first on the top of <to be expanded>:
	s/^(.*-\n)([^\n]+\n)/\2\1/
	# Remove if it is duplicate
	s/^(\<[^\n]+\n)(.*\n\1.*)$/\2/
	b generateTrampoline_mergeRequirements
# }}}

# {{{ generateTrampoline_allExpanded: process the final list
# Process the list, save it in the hold space, proceed with generating
# trampoline subroutine.
:generateTrampoline_allExpanded
	# lift main.sed on top
	s/^main\.sed\n//m
	s/^/main.sed\n/
	h
	b generateTrampoline_readLabels
# }}}

# {{{ generateTrampoline_readLabels: read labels from given files
:generateTrampoline_readLabels
	s/\n/ /g
	s,^,sed -Ene 's/^\\s*:(\\w+).*$/\\1/p' -- ,
	e
	b generateTrampoline_writeBlocks
# }}}

# {{{ generateTrampoline_writeBlocks: write label blocks
:generateTrampoline_writeBlocks
	s/\n*$/\n/
	s|^(\w+)$|\ts/^(stack:)\1,/\\1/m\n\t\tT trampoline_no_\1\n\t\tx ; b \1\n\t:trampoline_no_\1|mg
	b generateTrampoline_writeHeader
# }}}

# {{{ generateTrampoline_writeHeader: insert trampoline header
:generateTrampoline_writeHeader
	s/^/:trampoline\n\tt trampoline\n\tx\n/
	s/^/# Generated automatically by generateTrampoline script.\n/
	b generateTrampoline_writeFooter
# }}}

# {{{ generateTrampoline_writeFooter: append trampoline footer
:generateTrampoline_writeFooter
	s/$/\t:trampoline_halt\n/
	s/$/\t\tx\n/
	s/$/\t\ts,^,trampoline: Unexpected callback!\\n,\n/
	s/$/\t\tb err\n/
	b generateTrampoline_dump
# }}}

# {{{ generateTrampoline_dump: write subroutine to a file
# Dumps a whole trampoline subroutine to trampoline.sed file,
# sends final list of all script files to stdout.
:generateTrampoline_dump
	w trampoline.sed
	g
	s/\n+$//
	p
	Q
# }}}

# vim: foldmethod=marker
