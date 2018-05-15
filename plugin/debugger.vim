function! OpenSoarDebugger(...)
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

function! SetupDebuggerPanes()
	exec "e __MAIN_PANE__"
	exec "setlocal buftype=nofile"
	exec "setlocal bufhidden=hide"
	exec "setlocal noswapfile"
	exec "vs"
	exec "wincmd l"
	exec "e __SIDE_PANE_TOP__"
	exec "setlocal buftype=nofile"
	exec "setlocal bufhidden=hide"
	exec "setlocal noswapfile"
	exec "sp"
	exec "wincmd j"
	exec "e __SIDE_PANE_MID__"
	exec "setlocal buftype=nofile"
	exec "setlocal bufhidden=hide"
	exec "setlocal noswapfile"
	exec "sp"
	exec "wincmd j"
	exec "e __SIDE_PANE_BOT__"
	exec "setlocal buftype=nofile"
	exec "setlocal bufhidden=hide"
	exec "setlocal noswapfile"
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

def step(num):
	agent.agent.RunSelf(num)
	agent.update_debugger_info()

def reset_debugger():
	writer.clear_all_windows()
	agent.reset()

def close_debugger():
	agent.kill()
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


