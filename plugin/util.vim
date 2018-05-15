" Look for a source file in the current directory (named <dir>_source.soar)
" Append a soar command to source the current file to that source file
function! AddFileToSoarSource()
	let dir = expand('%:p:h')
	let source_file = dir."/".expand('%:p:h:t')."_source.soar"
	let file = expand('%:t')
	execute ":call system(\"echo \'\nsource ".file."\' >> ".source_file."\")"
	echo "Added ".file." to ".expand('%:p:h:t')."_source.soar"
endfunction

