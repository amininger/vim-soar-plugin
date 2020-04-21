
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


""""""""""""""""" OPENING FILES """""""""""""""""""""

" OpenSoarProductionInNewTab(prod_name)
" Will look for all files under g:root_agent_directory
"   that define the production with the given name (sp {prod_name )
" And open each one as in a new tab
function! OpenSoarProductionInNewTab(rule_name)
	if !exists("g:root_agent_directory")
		echo "Need to define g:root_agent_directory to open production"
		return
	endif

	" Note: we substitute * with . in the rule_name for grep to work properly
	let command = "grep -nR \"sp {".substitute(a:rule_name, "*", ".", "g")." *$\" ".g:root_agent_directory
	let lines = split(system(command), "\n")
	for line in lines
		let parts = split(line, ":")
		if len(parts) >= 2
			let filename = parts[0]
			let line_num = parts[1]
			if filename =~ ".soar$"
				let rel_filename = fnamemodify(filename, ":~:.")
				execute "tabe +".line_num." ".rel_filename
			endif
		endif
	endfor
endfunction


""""""""""""""""" DELETING """""""""""""""""""""

" DeleteSoarProduction(line_num)
"   Deletes the production at the given line number
"   (or cursor position if no line_num is given)
function! DeleteSoarProduction(...)
	let line_num = a:0 > 0 ? a:1 : line('.')
	let prod_info = GetSoarProductionInfo(line_num)
    if len(prod_info) > 2
        execute ":".prod_info[0].",".prod_info[1]."d"
    endif
endfunction

""""""""""""""""" COMMENTING """""""""""""""""""""

" CommentSoarProduction(line_num)
"   Comments the production at the given line number (prepend with #)
"   (or cursor position if no line_num is given)
function! CommentSoarProduction(...)
	let line_num = a:0 > 0 ? a:1 : line('.')
	let prod_info = GetSoarProductionInfo(line_num)
	if len(prod_info) > 2
		execute ":".prod_info[0].",".prod_info[1]."s/^/#/"
	endif
endfunction

" UncommentSoarProduction(line_num)
"   Uncomments the production at the given line number (removes prefix #)
"   (or cursor position if no line_num is given)
function! UncommentSoarProduction(...)
	let line_num = a:0 > 0 ? a:1 : line('.')
	let prod_info = GetSoarProductionInfo(line_num, 1)
	if len(prod_info) > 2
		execute ":".prod_info[0].",".prod_info[1]."s/^#//"
	endif
endfunction


