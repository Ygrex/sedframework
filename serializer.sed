#!/bin/sed -Enf

# Requires: framework/exceptions.sed, trampoline.sed

# Module distributed with sedframework.
# Provides serialization subroutines to store/restore pattern space snapshots.

# {{{ serializer_push: store pattern
# Naive implementation of serializer.
# Current content of the pattern preserved.
:serializer_push
	s/\n/\x01/g
	s/^/serializer:/
	H
	s/^serializer://
	s/\x01/\n/g
	b trampoline
# }}}

# {{{ serializer_pop: restore pattern and remove the saved copy
# Restores content previously serialized with serializer_push.
# Current content of the pattern destroyed.
:serializer_pop
	# serialize current content
	s/\n/\x01/g
	s/^/serializer:/
	# append the whole hold space, a previously stored pattern there
	G
	# remove lines beginning with special marker \x01
	s/^\x01.*$//mg
	# append \x01 marker to 'serializer' tagged lines
	s/^serializer:/\x01&/mg
	# remove all other lines
	s/^[^\x01].*$//mg
	# throw away any trailing newlines
	s/\n+$//
	# reset conditional flag
	:serializer_pop_noop_1
		t serializer_pop_noop_1
	# remove everything but first and last tagged lines
	s/\`\x01serializer:(.*)$(.*\n?)*^\x01serializer:(.*)\'/\1\3/m
	T serializer_pop_notFound
	# naive deserialization reverse to 'serializer_push'
	s/\x01/\n/g
	# pattern now have all the original content and the restored one
	# reset conditional flag
	:serializer_pop_noop_2
		t serializer_pop_noop_2
	# last duty is to remove the stored one from the hold space
	x
	s/\`((.*\n?)*)^serializer:.*$((.*\n?)*)\'/\1\3/m
	x
	T serializer_pop_notFound
	b trampoline
	:serializer_pop_notFound
		s/^/serializer_pop: no stored pattern found!\n/
		b err
# }}}

# vim: foldmethod=marker
