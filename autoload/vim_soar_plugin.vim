" Make sure python is installed (either python2 or python3)
if has('python')
	command! -nargs=1 Python python <args>
elseif has('python3')
	command! -nargs=1 Python python3 <args>
else
	echo 'Error: vim-soar-plugin debugger requires +python or +python3'
	finish
endif

" Add the python directory to the python path
Python << EOF
import sys
from os.path import normpath, join
import vim

plugin_root_dir = vim.eval('g:vim_soar_plugin_root_dir')
python_root_dir = normpath(join(plugin_root_dir, 'python'))
sys.path.insert(0, python_root_dir)
EOF

" Contains functions for running a soar agent within vim
exec "source ".g:vim_soar_plugin_root_dir."/autoload/debugger.vim"

" Contains rosie-specific functionality
exec "source ".g:vim_soar_plugin_root_dir."/autoload/rosie.vim"

" Contains custom commands and key mappings
exec "source ".g:vim_soar_plugin_root_dir."/autoload/mappings.vim"

function! vim_soar_plugin#OpenSoarDebugger(...)
	let config_file = ""
	if a:0 == 1
		let config_file = a:1
	endif
	echom config_file
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python agent = VimSoarAgent(writer, config_filename=vim.eval("config_file"))
	Python agent.connect()
endfunction

function! vim_soar_plugin#OpenRosieDebugger()
	let agent_name = input('Enter agent name: ', 'test-task-learning')
	let config_file = $ROSIE_HOME."/test-agents/".agent_name."/agent/rosie.".agent_name.".config"
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python from VimRosieAgent import VimRosieAgent
	Python agent = VimRosieAgent(writer, config_filename=vim.eval("config_file"))
	Python agent.connect()
endfunction

function! vim_soar_plugin#OpenRosieThorDebugger()
	let agent_name = input('Enter agent name: ', 'ai2thor')
	let config_file = $ROSIE_HOME."/test-agents/".agent_name."/agent/rosie.".agent_name.".config"
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python from VimRosieAgent import VimRosieAgent
	Python agent = VimRosieAgent(writer, config_filename=vim.eval("config_file"))
	call LaunchAi2ThorSimulator()
	Python agent.connect()
endfunction
