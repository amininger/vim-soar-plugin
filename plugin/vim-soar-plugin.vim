" Get directory of this file
let g:vim_soar_plugin_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

" Contains functions for parsing soar rules
exec "source ".g:vim_soar_plugin_root_dir."/plugin/parsing.vim"

" Contains general soar editing functions
exec "source ".g:vim_soar_plugin_root_dir."/plugin/editing.vim"

" Contains functions for inserting rule templates
exec "source ".g:vim_soar_plugin_root_dir."/plugin/templates.vim"


""""""""""""""""" Soar Plugin Commands """""""""""""""""""

" Looks for <dir>_source.soar in the same directory
" and appends a line sourcing the current soar file
command! -nargs=0 AddFileToSoarSource :call AddFileToSoarSource()

" Adds a source subdirectory command to the current file (pushd/source/popd)
" will autocomplete using current directories.
" Assumes subdirectory contains file dir_name_source.soar
command! -nargs=1 -complete=dir SourceSoarDirectory :call SourceSoarDirectory(<f-args>)

" Inserts a soar template into the current file
command! -nargs=1 -complete=customlist,ListSoarTemplates InsertSoarTemplate :call InsertSoarTemplate(<f-args>)

" The rest of the plugin is found in autoload
" Debugger commands aren't loaded until you call the OpenDebugger Command
command! -nargs=? -complete=file SoarDebugger :call vim_soar_plugin#OpenSoarDebugger(<f-args>)

command! RemoteDebugger :call vim_soar_plugin#OpenRemoteDebugger()

command! -nargs=? -complete=file RosieDebugger :call vim_soar_plugin#OpenRosieDebugger("internal", <f-args>)

command! -nargs=? -complete=file MobileDebugger :call vim_soar_plugin#OpenRosieDebugger("mobilesim", <f-args>)

command! -nargs=? -complete=file ThorDebugger :call vim_soar_plugin#OpenRosieDebugger("ai2thor", <f-args>)

command! -nargs=? -complete=file CozmoDebugger :call vim_soar_plugin#OpenRosieDebugger("cozmo", <f-args>)

