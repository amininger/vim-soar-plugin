" Make sure python is installed (either python2 or python3)
if has('python')
	command! -nargs=1 Python python <args>
elseif has('python3')
	command! -nargs=1 Python python3 <args>
else
	echo 'Error: vim-soar-debugger plugin requires +python or +python3'
	finish
endif

" If you set the global variable enable_soar_plugin_mappings to 0
" the plugin keybindings will be skipped
if !exists('g:enable_soar_plugin_mappings')
	let g:enable_soar_plugin_mappings = 1
endif

" Get directory of this file
let s:autoload_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" Add the python directory to the python path
Python << EOF
import sys
from os.path import normpath, join
import vim

autoload_root_dir = vim.eval('s:autoload_root_dir')
python_root_dir = normpath(join(autoload_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)
EOF

" Contains general soar utility functions
exec "source ".s:autoload_root_dir."/util.vim"

" Contains functions for parsing soar rules
exec "source ".s:autoload_root_dir."/parsing.vim"

" Contains functions for inserting rule templates
exec "source ".s:autoload_root_dir."/templates.vim"

" Contains functions for running a soar agent within vim
exec "source ".s:autoload_root_dir."/debugger.vim"

" Contains rosie-specific functionality
exec "source ".s:autoload_root_dir."/rosie.vim"

" Contains custom commands and key mappings
exec "source ".s:autoload_root_dir."/mappings.vim"
