" Vim syntax file
" Language:	GNU sed
" Maintainer:	Ygrex <ygrex@ygrex.ru>
" URL:		gopher://ygrex.ru
" Last Change:	2020 February 6

" Adds GNU extensions on top of sed.vim (by Haakon Riiser, rev. 2010 May 29)
" - a, i, c in one line
" - q, Q with exit code specified
" - T branch command
" - GNU specific s flags
" - e, z, R, W commands
" In order to install, copy the file to ~/.vim/after/syntax/sed.vim

syn match sedFunction	"\([qQ]\s*[[:digit:]]*\|[dDegGhHlnNpPxz=]\)\s*\($\|;\)" contains=sedSemicolon,sedWhitespace
syn region sedGnuACI	matchgroup=sedFunction start="[aci]" matchgroup=NONE end="$" contains=sedWhitespace
syn region sedBranch	matchgroup=sedFunction start="[btT]" matchgroup=sedSemicolon end=";\|$" contains=sedWhitespace
syn match sedFlag	    "[[:digit:]gmMpiIe]*w\=" contains=sedFlagwrite contained
syn region sedGnuRW	matchgroup=sedFunction start="[RW]" matchgroup=sedSemicolon end=";\|$" contains=sedWhitespace

" vim: sts=4 sw=4 ts=8
