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
" yank production (to vim buffer)
nnoremap <buffer> ;yp :let @" = GetCurrentSoarRuleBody()<CR>
" yank rule name (to vim buffer)
nnoremap <buffer> ;yr :let @" = GetCurrentSoarWord()<CR>
" copy production (to clipboard)
nnoremap <buffer> ;cp :let @+ = GetCurrentSoarRuleBody()<CR>
" copy rule name (to clipboard)
nnoremap <buffer> ;cr :let @+ = GetCurrentSoarWord()<CR>

"""""""""""""" editing.vim """""""""""""""""
" delete production
nnoremap <buffer> ;dp :call DeleteCurrentSoarRule()<CR>
" comment current production
nnoremap <buffer> ;#p :let @+ = CommentCurrentSoarRule()<CR>
nnoremap <buffer> ;3p :let @+ = CommentCurrentSoarRule()<CR>
" uncomment current production
nnoremap <buffer> ;u#p :let @+ = UncommentCurrentSoarRule()<CR>
nnoremap <buffer> ;u3p :let @+ = UncommentCurrentSoarRule()<CR>

"""""""""""""""" templates.vim """"""""""""""""""

" Searches for the next occurence of #!# and replaces it
" (Used to navigate an inserted soar template)
nnoremap <buffer> <C-P> :call FindNextInsert()<CR>
inoremap <buffer> <C-P> <ESC>:call FindNextInsert()<CR>


