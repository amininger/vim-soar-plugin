" If you set the global variable enable_soar_plugin_mappings to 0
" the plugin keybindings will be skipped
if !exists('g:enable_soar_plugin_mappings')
	let g:enable_soar_plugin_mappings = 1
endif

" Get directory of this file
let s:plugin_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')


" Contains general soar utility functions
exec "source ".s:plugin_root_dir."/util.vim"

" Contains functions for parsing soar rules
exec "source ".s:plugin_root_dir."/parsing.vim"

" Contains functions for inserting rule templates
exec "source ".s:plugin_root_dir."/templates.vim"

" Contains custom commands and key mappings
exec "source ".s:plugin_root_dir."/mappings.vim"


" The rest of the plugin is found in autoload
" Debugger commands aren't loaded until you call the OpenDebugger Command
command! -nargs=? -complete=file OpenDebugger :call vim_soar_debugger#OpenSoarDebugger(<f-args>)

