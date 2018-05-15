""""""""""""""""" Soar Plugin Commands """""""""""""""""""

" Looks for <dir>_source.soar in the same directory
" and appends a line sourcing the current soar file
command! -nargs=0 AddFileToSource :call AddFileToSoarSource()

" Inserts a soar template into the current file
command! -nargs=1 -complete=customlist,ListSoarTemplates InsertTemplate :call InsertSoarTemplate(<f-args>)


""""""""""""""""" Soar Plugin Key Mappings """""""""""""""""""

if !g:enable_soar_plugin_mappings
	finish
endif

"""""""""""""" parsing.vim """""""""""""""""

" delete production
nnoremap ;dp :call DeleteCurrentSoarRule()<CR>
" yank production (to vim buffer)
nnoremap ;yp :let @" = GetCurrentSoarRuleBody()<CR>
" yank rule name (to vim buffer)
nnoremap ;yr :let @" = GetStrippedCurrentWord()<CR>
" copy production (to clipboard)
nnoremap ;cp :let @+ = GetCurrentSoarRuleBody()<CR>
" copy rule name (to clipboard)
nnoremap ;cr :let @+ = GetStrippedCurrentWord()<CR>

"""""""""""""""" templates.vim """"""""""""""""""

" Searches for the next occurence of #!# and replaces it
" (Used to navigate an inserted soar template)
nnoremap <C-P> :call FindNextInsert()<CR>
inoremap <C-P> <ESC>:call FindNextInsert()<CR>

