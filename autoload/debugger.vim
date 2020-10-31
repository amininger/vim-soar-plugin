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
agent = None

SOAR_GLOBAL_STATE = {}
run_thread = None

def step(num):
	global agent
	if agent is not None:
		agent.agent.RunSelf(num)
		agent.update_debugger_info()

def run_silent(num_dcs):
	global agent
	if agent is not None:
		num_dcs = int(num_dcs)
		agent.start_buffering_output()
		agent.agent.RunSelf(num_dcs)
		agent.stop_buffering_output()
		agent.update_debugger_info()

def run_slow(num_dcs):
	global agent
	if agent is not None:
		num_dcs = int(num_dcs)
		agent.dc_sleep = 0.001
		if num_dcs == -1:
			agent.agent.ExecuteCommandLine("run")
		else:
			agent.agent.RunSelf(num_dcs)
		agent.update_debugger_info()
		agent.dc_sleep = 0.0

def reset_debugger():
	global agent
	if agent is not None:
		writer.clear_all_windows()
		agent.reset()

def close_debugger():
	global agent
	if agent is not None:
		agent.kill()
		agent = None
		if simulator:
			simulator.stop()
		if run_thread:
			SOAR_GLOBAL_STATE["running"] = False
			run_thread.join()
		while len(vim.windows) > 1:
			vim.command("q!")
		vim.command("e! temp")
EOF

endfunction

function! ExecuteUserSoarCommand()
	let cmd = input('Enter command: ')
	Python agent.execute_command(vim.eval("cmd"), True)
	Python agent.update_debugger_info()
endfunction

function! SourceSoarFile(filename)
	call ExecuteSoarCommand("source ".a:filename)
endfunction

function! ExecuteSoarCommand(cmd)
	Python agent.execute_command(vim.eval("a:cmd"), True)
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

" Will source a rule that interrupts when the given operator is proposed
function! AddPInterrupt(op_name)
	let prod = "sp {DEBUGGER*INTERRUPT*".a:op_name." (state <s> ^operator (<o> ^name ".a:op_name.") +) --> (interrupt) }"
	call ExecuteSoarCommand(prod)
endfunction

" Will source a rule that interrupts when the given operator is selected
function! AddSInterrupt(op_name)
	let prod = "sp {DEBUGGER*INTERRUPT*".a:op_name." (state <s> ^operator (<o> ^name ".a:op_name.")) --> (interrupt) }"
	call ExecuteSoarCommand(prod)
endfunction

" Will excise an interrupt rule for the given operator
function! RemoveInterrupt(op_name)
	call ExecuteSoarCommand("excise DEBUGGER*INTERRUPT*".a:op_name)
endfunction

" Will excise all interrupt rules created by the debugger
function! RemoveAllInterrupts()
	Python from DebuggerUtil import excise_rules_matching_pattern
	Python excise_rules_matching_pattern(agent, "DEBUGGER*INTERRUPT*")
endfunction

""" Will print out any chunks matching the given pattern
function! FilterChunks(pattern)
	Python from DebuggerUtil import get_filtered_chunks, insert_text_at_cursor
	Python insert_text_at_cursor(get_filtered_chunks(agent, vim.eval('a:pattern')))
endfunction

""" Will print out any rules matching the given pattern
function! FilterRules(pattern)
	Python from DebuggerUtil import get_filtered_rules, insert_text_at_cursor
	Python insert_text_at_cursor(get_filtered_rules(agent, vim.eval('a:pattern')))
endfunction

""" Will write out all productions that have fired to a file with the given name
function! ExtractFiredRules(filename)
	Python from DebuggerUtil import write_fired_rules
	Python write_fired_rules(agent, vim.eval('a:filename'))
endfunction

""" Will print out the bottom state on the task stack to the given depth
function! PrintCurrentState(depth)
    Python from DebuggerUtil import get_current_substate, print_id
    Python state_id = get_current_substate(agent)
	Python writer.write(print_id(agent, state_id, vim.eval('a:depth')))
endfunction

""" Will print out the current operator to the given depth
function! PrintCurrentOperator(depth)
    Python from DebuggerUtil import get_current_operator, print_id
    Python op_id = get_current_operator(agent)
	Python writer.write(print_id(agent, op_id, vim.eval('a:depth')))
endfunction

""" Will print out the top-state rosie world in a pretty format
function! PrintRosieWorld()
	Python writer.write(pretty_print_world(agent.execute_command("pworld -d 4")))
endfunction

""" Will delete all wait lines at the end of the debugger window
"   (Lines where a wait operator is selected)
function! RemoveWaits()
	let last_line_num = line('$')
	let cur_line = last_line_num

	" Go backward from the end as long as each line is empty or a wait operator
	while getline(cur_line) =~ 'O:.*(wait)' || getline(cur_line) =~ '^\s*$'
		let cur_line = cur_line - 1
	endwhile
	let cur_line += 1
	
	if last_line_num >= cur_line
		let del_cmd = ":".cur_line.",".last_line_num."d"
		execute del_cmd
	endif
endfunction


