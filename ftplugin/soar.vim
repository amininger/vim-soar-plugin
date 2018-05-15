setlocal tabstop=3
setlocal shiftwidth=3

setlocal expandtab


""""""""""""""""" Soar Plugin Key Mappings """""""""""""""""""

" If you set the global variable enable_soar_plugin_mappings to 0
" the plugin keybindings will be skipped
if !exists('g:enable_soar_plugin_mappings')
	let g:enable_soar_plugin_mappings = 1
endif
if !g:enable_soar_plugin_mappings
	finish
endif

"""""""""""""" parsing.vim """""""""""""""""

" delete production
nnoremap <buffer> ;dp :call DeleteCurrentSoarRule()<CR>
" yank production (to vim buffer)
nnoremap <buffer> ;yp :let @" = GetCurrentSoarRuleBody()<CR>
" yank rule name (to vim buffer)
nnoremap <buffer> ;yr :let @" = GetStrippedCurrentWord()<CR>
" copy production (to clipboard)
nnoremap <buffer> ;cp :let @+ = GetCurrentSoarRuleBody()<CR>
" copy rule name (to clipboard)
nnoremap <buffer> ;cr :let @+ = GetStrippedCurrentWord()<CR>

"""""""""""""""" templates.vim """"""""""""""""""

" Searches for the next occurence of #!# and replaces it
" (Used to navigate an inserted soar template)
nnoremap <buffer> <C-P> :call FindNextInsert()<CR>
inoremap <buffer> <C-P> <ESC>:call FindNextInsert()<CR>


