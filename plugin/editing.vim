
"
"Look for a source file in the current directory (named <dir>_source.soar)
" Append a soar command to source the current file to that source file
function! AddFileToSoarSource()
	let dir = expand('%:p:h')
	let source_file = dir."/".expand('%:p:h:t')."_source.soar"
	let file = expand('%:t')
	execute ":call system(\"echo \'\nsource ".file."\' >> ".source_file."\")"
	echo "Added ".file." to ".expand('%:p:h:t')."_source.soar"
endfunction

" Will add lines to the current file that source the given directory
" (pushd/source/popd), assumes that there is a file {soar_dir}_source.soar
function! SourceSoarDirectory(soar_dir)
	" Remove trailing slash if it exists
	let trimmed_dir = substitute(a:soar_dir, '/$', '', '')
	call append(line('.'), [ 'pushd '.trimmed_dir, 'source '.trimmed_dir.'_source.soar', 'popd' ])
endfunction

" Deletes the production at the given line number
function! DeleteSoarRule(line_num)
	let rule_info = GetSoarRuleInfo(a:line_num, g:UNCOMMENTED_SOAR_RULE)
    if len(rule_info) > 2
        execute ":".rule_info[0].",".rule_info[1]."d"
    endif
endfunction

" Deletes the production at the current cursor position
function! DeleteCurrentSoarRule()
	let rule_info = GetSoarRuleInfo(line('.'), g:UNCOMMENTED_SOAR_RULE)
    if len(rule_info) > 2
        execute ":".rule_info[0].",".rule_info[1]."d"
    endif
endfunction

" Comments the production at the given line number (prepend with #)
function! CommentCurrentSoarRule(line_num)
	let rule_info = GetSoarRuleInfo(a:line_num, g:UNCOMMENTED_SOAR_RULE)
	if len(rule_info) > 2
		execute ":".rule_info[0].",".rule_info[1]."s/^/#/"
	endif
endfunction

" Comments the production at the current cursor position (prepend with #)
function! CommentCurrentSoarRule()
	let rule_info = GetSoarRuleInfo(line('.'), g:UNCOMMENTED_SOAR_RULE)
	if len(rule_info) > 2
		execute ":".rule_info[0].",".rule_info[1]."s/^/#/"
	endif
endfunction

" Uncomments the production at the given line number (removes prefix #'s)
function! UncommentSoarRule(line_num)
	let rule_info = GetSoarRuleInfo(a:line_num, g:COMMENTED_SOAR_RULE)
	if len(rule_info) > 2
		execute ":".rule_info[0].",".rule_info[1]."s/^#//"
	endif
endfunction

" Uncomments the production at the current cursor position (removes prefix #'s)
function! UncommentCurrentSoarRule()
	let rule_info = GetSoarRuleInfo(line('.'), g:COMMENTED_SOAR_RULE)
	if len(rule_info) > 2
		execute ":".rule_info[0].",".rule_info[1]."s/^#//"
	endif
endfunction
