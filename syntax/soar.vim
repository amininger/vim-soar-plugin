" Vim indent file
" Language:    Soar
" Maintainer:  Aaron Mininger
" Latest Revision: May 2020

if exists("b:current_syntax")
	finish
endif

" Adds dashes to what is considered a keyword, 
"   so commands that involve a whole word (such as movement w/b and
"   autocomplete) will consider a word like top-state as one word
set iskeyword+=-

let b:current_syntax = "soar"

syn match soarComment "#.*$"
hi soarComment ctermfg=lightgray

syn match soarIdentifier "<[a-zA-Z0-9_-]\+>" contained
"hi def link soarIdentifier Type
hi soarIdentifier ctermfg=lightblue

syn match soarAttribute "\^[a-zA-Z0-9._-]*" contained
"hi def link soarAttribute Normal
hi soarAttribute ctermfg=white

syn match soarValue " [a-zA-Z0-9._-]\+" contained
syn match soarValue "|.*|" contained
syn match soarValue "@[a-zA-Z0-9_-]\+" contained
"hi def link soarValue Constant
hi soarValue ctermfg=lightyellow

syn match soarRuleName "[a-zA-Z0-9_-]\+\*[a-zA-Z0-9*_-]* *$" contained
"hi def link soarRuleName Function
hi soarRuleName cterm=bold ctermfg=lightgreen

syn region soarWme start="(" end=")" contains=soarNameWme,soarIdentifier,soarAttribute,soarValue,soarRhsKeyword contained
syn match soarNames "\( [a-zA-Z0-9_-]\+\)\+" contained
syn match soarNameWme "\^name.*\($\|[)^]\)" contains=soarNames contained
syn match soarNameWme "\^operator\.name.*\($\|[)^]\)" contains=soarNames contained
syn match soarNameWme "\^superstate\.name.*\($\|[)^]\)" contains=soarNames contained
hi def link soarNames Identifier
hi soarNames ctermfg=lightgreen
hi soarNameWme ctermfg=white


"syn keyword soarCommandKeyword alias chunk debug decide echo epmem explain file-system gp
"syn keyword soarCommandKeyword help load output preferences print production run rl save
"syn keyword soarCommandKeyword soar smem srand stats svs trace visualize wm
"hi def link soarCommandKeyword Keyword

syn keyword soarRhsKeyword halt interrupt write crlf exec cmd dont-learn force-learn contained
syn keyword soarRhsKeyword div mod abs atan2 sqrt sin cos int float contained
syn keyword soarRhsKeyword timestamp make-constant-symbol capitalize-symbol contained state
hi def link soarRhsKeyword Keyword

syn region soarProduction start="^sp" end="}" fold contains=soarRuleName,soarComment,soarWme
" syn region smemCommand start="^smem --add" end="}" fold contains=soarWme

