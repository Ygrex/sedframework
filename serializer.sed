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

# {{{ serializer_get: restore pattern, keep the saved copy untouched
# Restores content previously serialized with serializer_push.
# To the current content of the pattern the snapshot is added as-is
# with no \n automatically added.
:serializer_get
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
	:serializer_get_noop_1
		t serializer_get_noop_1
	# remove everything but first and last tagged lines
	s/\`\x01serializer:(.*)$(.*\n?)*^\x01serializer:(.*)\'/\1\3/m
	T serializer_get_notFound
	# naive deserialization reverse to 'serializer_push'
	s/\x01/\n/g
	b trampoline
	:serializer_get_notFound
		s/^/serializer_get: no stored pattern found!\n/
		b err
# }}}

# {{{ serializer_forget: remove the latest saved copy
:serializer_forget
	x
	s/\`((.*\n?)*)^serializer:.*$((.*\n?)*)\'/\1\3/m
	x
	t trampoline
	s/^/serializer_forget: no stored pattern found!\n/
	b err
# }}}

# {{{ serializer_pop: restore pattern and remove the saved copy
# Restores content previously serialized with serializer_push.
# To the current content of the pattern the snapshot is added as-is
# with no \n automatically added.
:serializer_pop
	x ; s/^stack:/&serializer_get,serializer_forget,/m ; x
	b trampoline
# }}}

# {{{ serializer_replace: replace the last saved copy
:serializer_replace
	x ; s/^stack:/&serializer_forget,serializer_push,/m ; x
	b trampoline
# }}}

# vim: foldmethod=marker
