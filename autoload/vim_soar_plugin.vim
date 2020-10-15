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


" Will open the soar debugging environment
"   You can optionally specify a config file to use when creating the agent
function! vim_soar_plugin#OpenSoarDebugger(...)
	" If an argument is given, it is the config filename
	let config_file = ""
	if a:0 > 0
		let config_file = a:1
	endif
	if config_file != "" && !filereadable(config_file)
		echom "The given config file ".config_file." does not exist"
		return
	endif
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python simulator = None
	Python agent = VimSoarAgent(writer, config_filename=vim.eval("config_file"))
	Python agent.connect()
endfunction

" Will connect to a remote kernel and allow you to debug it
function! vim_soar_plugin#OpenRemoteDebugger(...)
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python simulator = None
	Python agent = VimSoarAgent(writer, remote_connection=True)
	Python agent.connect()
endfunction

" Will open a rosie-specific debugger
"   env defines which environment interface to use and 
"       can be one of { internal, mobilesim, ai2thor, cozmo }
"   config_file is optional and specifies how to initialize the config file
function! vim_soar_plugin#OpenRosieDebugger(env, ...)
	" If a second argument is given, it is the config filename
	let config_file = ""
	if a:0 > 0
		let config_file = a:1
	else
		let agent_name = input('Enter agent name: ', g:default_rosie_agent)
		let config_file = $ROSIE_HOME."/test-agents/".agent_name."/agent/rosie.".agent_name.".config"
	endif
	if !filereadable(config_file)
		echom "The given config file ".config_file." does not exist"
		return
	endif
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python from VimRosieAgent import VimRosieAgent
	Python simulator = None
	Python agent = VimRosieAgent(writer, config_filename=vim.eval("config_file"), domain=vim.eval("a:env"))
	call SetupRosieInterface(a:env)
	Python agent.connect()
endfunction

