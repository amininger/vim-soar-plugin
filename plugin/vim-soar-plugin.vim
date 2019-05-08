" Get directory of this file
let g:vim_soar_plugin_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

" Contains general soar utility functions
exec "source ".g:vim_soar_plugin_root_dir."/plugin/util.vim"

" Contains functions for parsing soar rules
exec "source ".g:vim_soar_plugin_root_dir."/plugin/parsing.vim"

" Contains functions for inserting rule templates
exec "source ".g:vim_soar_plugin_root_dir."/plugin/templates.vim"


""""""""""""""""" Soar Plugin Commands """""""""""""""""""

" Looks for <dir>_source.soar in the same directory
" and appends a line sourcing the current soar file
command! -nargs=0 AddFileToSource :call AddFileToSoarSource()

" Inserts a soar template into the current file
command! -nargs=1 -complete=customlist,ListSoarTemplates InsertSoarTemplate :call InsertSoarTemplate(<f-args>)

" The rest of the plugin is found in autoload
" Debugger commands aren't loaded until you call the OpenDebugger Command
command! -nargs=? -complete=file OpenDebugger :call vim_soar_plugin#OpenSoarDebugger(<f-args>)

command! -nargs=0 -complete=file RosieDebugger :call vim_soar_plugin#OpenRosieDebugger()

command! -nargs=0 -complete=file ThorDebugger :call vim_soar_plugin#OpenRosieThorDebugger()

command! -nargs=0 -complete=file CozmoDebugger :call vim_soar_plugin#OpenRosieCozmoDebugger()
