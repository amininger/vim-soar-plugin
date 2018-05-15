" The rest of the plugin is found in autoload
" Debugger commands aren't loaded until you call the OpenDebugger Command
command! -nargs=? -complete=file OpenDebugger :call vim-soar-debugger#OpenSoarDebugger(<f-args>)

