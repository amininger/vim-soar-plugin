" Vim indent file
" Language:    Soar
" Maintainer:  Aaron

if exists("b:did_soar_indent")
	finish
endif
let b:did_soar_indent = 1

setlocal indentexpr=GetSoarIndent(v:lnum)
setlocal indentkeys&
setlocal indentkeys+=<>>

if exists("*GetSoarIndent")
	finish
endif

function! s:GetPrevNonCommentLineNum( line_num )

	" Skip lines starting with a comment
	let SKIP_LINES = '^\s*#'

	let nline = a:line_num
	while nline > 0
		let nline = prevnonblank(nline-1)
		if getline(nline) !~? SKIP_LINES
			break
		endif
	endwhile

	return nline
endfunction


function! GetSoarIndent( line_num )
	" Line 0 always goes at column 0
	if a:line_num == 0
		return 0
	endif

	let this_codeline = getline( a:line_num )

    " Expressions starting with '-->' or '}' get no indent
    if this_codeline =~ '^\s*\(-->\|}\)'
        return 0
    endif

	let prev_codeline_num = s:GetPrevNonCommentLineNum( a:line_num )
	let prev_codeline = getline( prev_codeline_num )
	let indnt = indent( prev_codeline_num )

    " Line ends with a parenthesis, go back to normal
    if prev_codeline =~ ')$'
        return &shiftwidth
    endif
    if prev_codeline =~ ')}$'
        return &shiftwidth
    endif

    " Comes after a comment or is a comment, use same indent
    if this_codeline =~ '^\s*#'
        return indnt
    endif
    if prev_codeline =~ '^\s*#'
        return indnt
    endif

    " Coming after a rule, no indent
    if prev_codeline =~ '^\s*}'
        return 0
    endif

    " Coming after sp{ or --> so do a normal indent
    if prev_codeline =~ '^\s*\(sp\s*{\|-->\)'
        return &shiftwidth
    endif

    " If there's an unmatched parenthesis, use the ^ for indenting
    if prev_codeline =~ '^\s*.*([^)]*$'
        if prev_codeline =~ '\^'
            for i in range(len(prev_codeline))
                if prev_codeline[i-1] == "^"
                    return i - 1
                endif
            endfor
        else
            return indnt + &shiftwidth
        endif
    endif


    return indnt
endfunction

