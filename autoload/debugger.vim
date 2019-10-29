function! SetupDebuggerPanes()
	exec "e __MAIN_PANE__"
	exec "setlocal buftype=nofile"
	exec "setlocal bufhidden=hide"
	exec "setlocal noswapfile"
	exec "setfiletype soar"
	exec "vs"
	exec "wincmd l"
	exec "e __SIDE_PANE_TOP__"
	exec "setlocal buftype=nofile"
	exec "setlocal bufhidden=hide"
	exec "setlocal noswapfile"
	exec "setfiletype soar"
	exec "sp"
	exec "wincmd j"
	exec "e __SIDE_PANE_MID__"
	exec "setlocal buftype=nofile"
	exec "setlocal bufhidden=hide"
	exec "setlocal noswapfile"
	exec "setfiletype soar"
	exec "sp"
	exec "wincmd j"
	exec "e __SIDE_PANE_BOT__"
	exec "setlocal buftype=nofile"
	exec "setlocal bufhidden=hide"
	exec "setlocal noswapfile"
	exec "setfiletype soar"
	exec "wincmd h"
Python << EOF

def resize_windows():
	vim.current.window = writer.get_window(VimWriter.MAIN_PANE)
	vim.command("let cur_winh = winheight(0)")
	height = int(vim.eval("cur_winh"))

	vim.command("let cur_winw1 = winwidth(0)")
	width = int(vim.eval("cur_winw1"))

	vim.current.window = writer.get_window(VimWriter.SIDE_PANE_TOP)
	vim.command("let cur_winw2 = winwidth(0)")
	width += int(vim.eval("cur_winw2"))

	vim.command("resize " + str(int(height/3)))
	vim.command("vertical resize " + str(int(width/3)))

	vim.current.window = writer.get_window(VimWriter.SIDE_PANE_MID)
	vim.command("resize " + str(int(height/3)))

	vim.current.window = writer.get_window(VimWriter.MAIN_PANE)
EOF
endfunction

function! SetupAgentMethods()

Python << EOF
import sys
import os
import vim

from VimSoarAgent import VimSoarAgent
from VimWriter import VimWriter

writer = VimWriter()

GLOBAL_STATE = {}
run_thread = None

def step(num):
	agent.agent.RunSelf(num)
	agent.update_debugger_info()

def run_silent(num_dcs):
	agent.start_buffering_output()
	agent.agent.RunSelf(num_dcs)
	agent.stop_buffering_output()
	agent.update_debugger_info()

def reset_debugger():
	writer.clear_all_windows()
	agent.reset()

def close_debugger():
	agent.kill()
	if simulator:
		simulator.stop()
	if run_thread:
		GLOBAL_STATE["running"] = False
		run_thread.join()
	while len(vim.windows) > 1:
		vim.command("q!")
	vim.command("e! temp")

resize_windows()
EOF

endfunction

function! ExecuteUserSoarCommand()
	let cmd = input('Enter command: ')
	Python agent.execute_command(vim.eval("cmd"))
	Python agent.update_debugger_info()
endfunction

function! SourceSoarFile(filename)
	call ExecuteSoarCommand("source ".a:filename)
endfunction

function! ExecuteSoarCommand(cmd)
	Python agent.execute_command(vim.eval("a:cmd"))
endfunction

function! SaveSimulatorState()
	Python if simulator: simulator.save()
endfunction

" Will reject all operators with the given name for 1 elaboration cycle,
" enough to re-enter the op no-change substate (useful when debugging)
function! RejectSoarOperator(op_name)
	let rej_prod = "sp {DEBUG*REJ (state <s> ^operator (<o> ^name ".a:op_name.") +) --> (<s> ^operator <o> -) }"
	call ExecuteSoarCommand(rej_prod)
	call ExecuteSoarCommand("step")
	call ExecuteSoarCommand("excise DEBUG*REJ")
endfunction


