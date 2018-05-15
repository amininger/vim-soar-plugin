" Get directory of this file
let s:plugin_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" Contains general soar utility functions
exec "source ".s:plugin_root_dir."/util.vim"

" Contains functions for parsing soar rules
exec "source ".s:plugin_root_dir."/parsing.vim"

" Contains functions for inserting rule templates
exec "source ".s:plugin_root_dir."/templates.vim"


""""""""""""""""" Soar Plugin Commands """""""""""""""""""

" Looks for <dir>_source.soar in the same directory
" and appends a line sourcing the current soar file
command! -nargs=0 AddFileToSource :call AddFileToSoarSource()

" Inserts a soar template into the current file
command! -nargs=1 -complete=customlist,ListSoarTemplates InsertSoarTemplate :call InsertSoarTemplate(<f-args>)

" The rest of the plugin is found in autoload
" Debugger commands aren't loaded until you call the OpenDebugger Command
command! -nargs=? -complete=file OpenDebugger :call vim_soar_plugin#OpenSoarDebugger(<f-args>)
