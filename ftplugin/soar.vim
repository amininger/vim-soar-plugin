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
nnoremap <buffer> ;yp :let @" = GetSoarProductionBody()<CR>
" yank rule name (to vim buffer)
nnoremap <buffer> ;yr :let @" = GetSoarWord()<CR>
" copy production (to clipboard)
nnoremap <buffer> ;cp :let @+ = GetSoarProductionBody()<CR>
" copy rule name (to clipboard)
nnoremap <buffer> ;cr :let @+ = GetSoarWord()<CR>

"""""""""""""" editing.vim """""""""""""""""
" delete production
nnoremap <buffer> ;dp :call DeleteSoarProduction()<CR>
" comment current production
nnoremap <buffer> ;#p :let @+ = CommentSoarProduction()<CR>
nnoremap <buffer> ;3p :let @+ = CommentSoarProduction()<CR>
" uncomment current production
nnoremap <buffer> ;u#p :let @+ = UncommentSoarProduction()<CR>
nnoremap <buffer> ;u3p :let @+ = UncommentSoarProduction()<CR>

"""""""""""""""" templates.vim """"""""""""""""""

" Searches for the next occurence of #!# and replaces it
" (Used to navigate an inserted soar template)
nnoremap <buffer> <C-P> :call FindNextInsert()<CR>
inoremap <buffer> <C-P> <ESC>:call FindNextInsert()<CR>


