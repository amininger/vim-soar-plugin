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
	Python simulator = None
	Python agent = VimSoarAgent(writer, config_filename=vim.eval("config_file"))
	Python agent.connect()
endfunction

function! vim_soar_plugin#OpenRosieDebugger()
	let agent_name = input('Enter agent name: ', g:default_rosie_agent)
	if agent_name =~ "config" 
		let config_file = $ROSIE_HOME."/test-agents/".agent_name
	else
		let config_file = $ROSIE_HOME."/test-agents/".agent_name."/agent/rosie.".agent_name.".config"
	endif
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python from VimRosieAgent import VimRosieAgent
	Python simulator = None
	Python agent = VimRosieAgent(writer, config_filename=vim.eval("config_file"))
	Python agent.connect()
endfunction

function! vim_soar_plugin#OpenTaskTestDebugger(test_name)
	let config_file = $ROSIE_HOME."/test-agents/task-tests/".a:test_name."/agent/rosie.".a:test_name.".config"
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python from VimRosieAgent import VimRosieAgent
	Python simulator = None
	Python agent = VimRosieAgent(writer, config_filename=vim.eval("config_file"), watch_level="1", verbose="true")
	Python agent.connect()
endfunction

function! vim_soar_plugin#OpenRosieMobileDebugger()
	let agent_name = input('Enter agent name: ', g:default_rosie_agent)
	if agent_name =~ "config" 
		let config_file = $ROSIE_HOME."/test-agents/".agent_name
	else
		let config_file = $ROSIE_HOME."/test-agents/".agent_name."/agent/rosie.".agent_name.".config"
	endif
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python from VimRosieAgent import VimRosieAgent
	Python simulator = None
	Python agent = VimRosieAgent(writer, config_filename=vim.eval("config_file"))
	call LaunchMobileSimRosie()
	Python agent.connect()
endfunction

function! vim_soar_plugin#OpenRosieThorDebugger()
	let agent_name = input('Enter agent name: ', g:default_rosie_agent)
	if agent_name =~ "config" 
		let config_file = $ROSIE_HOME."/test-agents/".agent_name
	else
		let config_file = $ROSIE_HOME."/test-agents/".agent_name."/agent/rosie.".agent_name.".config"
	endif
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python from VimRosieAgent import VimRosieAgent
	Python simulator = None
	Python agent = VimRosieAgent(writer, config_filename=vim.eval("config_file"))
	call LaunchAi2ThorSimulator()
	Python agent.connect()
endfunction

function! vim_soar_plugin#OpenRosieCozmoDebugger()
	let agent_name = input('Enter agent name: ', g:default_rosie_agent)
	if agent_name =~ "config" 
		let config_file = $ROSIE_HOME."/test-agents/".agent_name
	else
		let config_file = $ROSIE_HOME."/test-agents/".agent_name."/agent/rosie.".agent_name.".config"
	endif
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python from VimRosieAgent import VimRosieAgent
	Python simulator = None
	Python agent = VimRosieAgent(writer, config_filename=vim.eval("config_file"))
	call LaunchCozmoRobot()
	Python agent.connect()
endfunction

