""""""""""""""""" Soar Plugin Commands """""""""""""""""""

" Commands for using the soar debugger
command! -nargs=0 CloseDebugger :Python close_debugger()
command! -nargs=0 ResetDebugger :Python reset_debugger()

" Source the current file into the running soar agent (debugger.vim)
command! -nargs=0 SourceFile :call ExecuteSoarCommand("source ".expand('%:p'))

" Source a specified file into the running soar agent (debugger.vim)
command! -nargs=1 -complete=file SourceSoarFile :call SourceSoarFile(<f-args>)

" Will reject all operators with the given name (helpful to reset a substate) (debugger.vim)
command! -nargs=1 RejectSoarOperator :call RejectSoarOperator(<f-args>)

" Will source a rule that interrupts when the given operator is proposed (debugger.vim)
command! -nargs=1 AddOpInterrupt :call AddOpInterrupt(<f-args>)

" Will excise an interrupt rule for the given operator (debugger.vim)
command! -nargs=1 RemoveOpInterrupt :call RemoveOpInterrupt(<f-args>)

" Will print out all chunks matching the given pattern
command! -nargs=1 FilterChunks :call FilterChunks(<f-args>)

" Will print out all rules matching the given pattern
command! -nargs=1 FilterRules :call FilterRules(<f-args>)

""""""""""""""""" Soar Plugin Key Mappings """""""""""""""""""

" If you set the global variable enable_soar_plugin_mappings to 0
" the plugin keybindings will be skipped
if !exists('g:enable_soar_plugin_mappings')
	let g:enable_soar_plugin_mappings = 1
endif
if !g:enable_soar_plugin_mappings
	finish
endif

" Change to the rosie/agent directory
nnoremap ;2ra :cd $ROSIE_AGENT<CR>

" Execute an arbitrary soar command
nnoremap # :call ExecuteUserSoarCommand()<CR>

" Run 1 elaboration cycle (run elab)
nnoremap ;re :Python agent.execute_command("run 1 -e", True)<CR>
" Run 1 dc
nnoremap H :Python step(1)<CR>
" Run 10 dc 
nnoremap U :Python step(10)<CR>
" Run 1000 dc (~ 1 sec)
nnoremap ;ru :Python run_silent(1000)<CR>
nnoremap ;rsu :Python run_slow(1000)<CR>
" Run forever (until interrupted) (This is generally bad, if soar doesn't hit an interrupt vim will hang)
nnoremap ;rf :Python agent.execute_command("run", True)<CR>

" Run custom number of dc's silently
command! -nargs=1 RunAgent :Python run_silent(<f-args>)<CR>

" Run custom number of dc's slowly
command! -nargs=1 RunSlow :Python run_slow(<f-args>)<CR>

" Key: ;r# means run 10^# decision cycles (e.g. ;r2 is run 100)
nnoremap ;r0 :Python step(1)<CR>
nnoremap ;r1 :Python run_silent(10)<CR>
nnoremap ;r2 :Python run_silent(100)<CR>
nnoremap ;r3 :Python run_silent(1000)<CR>
nnoremap ;r4 :Python run_silent(10000)<CR>
nnoremap ;r5 :Python run_silent(100000)<CR>
nnoremap ;r6 :Python run_silent(1000000)<CR>

" Run slowly (puts a delay between each decision cycle)
nnoremap ;rs1 :Python run_slow(10)<CR>
nnoremap ;rs2 :Python run_slow(100)<CR>
nnoremap ;rs3 :Python run_slow(1000)<CR>
nnoremap ;rs4 :Python run_slow(10000)<CR>
nnoremap ;rs5 :Python run_slow(100000)<CR>
nnoremap ;rs6 :Python run_slow(1000000)<CR>
" run slowly forever
nnoremap ;rsf :Python run_slow(-1)<CR>

" See which rules currently match
nnoremap ;ma :Python agent.execute_command("matches", True)<CR>

" source production
nnoremap ;sp :call ExecuteSoarCommand(GetSoarProductionBody())<CR>
" matches production
nnoremap ;mp :call ExecuteSoarCommand("matches ".GetSoarProductionName())<CR>
" excise production
nnoremap ;ep :call ExecuteSoarCommand("excise ".GetSoarProductionName())<CR>
" firing count of production
nnoremap ;fcp :call ExecuteSoarCommand("fc ".GetSoarProductionName())<CR>

" print rule by name
nnoremap ;pr :call ExecuteSoarCommand("p ".GetSoarWord())<CR>
" matches rule name
nnoremap ;mr :call ExecuteSoarCommand("matches ".GetSoarWord())<CR>
" excise rule name
nnoremap ;er :call ExecuteSoarCommand("excise ".GetSoarWord())<CR>
" firing count of rule name
nnoremap ;fcr :call ExecuteSoarCommand("fc ".GetSoarWord())<CR>

" print wmes
nnoremap ;p1 :call ExecuteSoarCommand("p ".GetSoarWord())<CR>
nnoremap ;p2 :call ExecuteSoarCommand("p ".GetSoarWord()." -d 2")<CR>
nnoremap ;p3 :call ExecuteSoarCommand("p ".GetSoarWord()." -d 3")<CR>
nnoremap ;p4 :call ExecuteSoarCommand("p ".GetSoarWord()." -d 4")<CR>
nnoremap ;p5 :call ExecuteSoarCommand("p ".GetSoarWord()." -d 5")<CR>
nnoremap ;p6 :call ExecuteSoarCommand("p ".GetSoarWord()." -d 6")<CR>
nnoremap ;p7 :call ExecuteSoarCommand("p ".GetSoarWord()." -d 7")<CR>
nnoremap ;p8 :call ExecuteSoarCommand("p ".GetSoarWord()." -d 8")<CR>
nnoremap ;p9 :call ExecuteSoarCommand("p ".GetSoarWord()." -d 9")<CR>

" print current state
nnoremap ;st :call PrintCurrentState(1)<CR>
nnoremap ;s1 :call PrintCurrentState(1)<CR>
nnoremap ;s2 :call PrintCurrentState(2)<CR>
nnoremap ;s3 :call PrintCurrentState(3)<CR>
nnoremap ;s4 :call PrintCurrentState(4)<CR>

" print current operator
nnoremap ;o1 :call PrintCurrentOperator(1)<CR>
nnoremap ;o2 :call PrintCurrentOperator(2)<CR>
nnoremap ;o3 :call PrintCurrentOperator(3)<CR>
nnoremap ;o4 :call PrintCurrentOperator(4)<CR>
nnoremap ;o5 :call PrintCurrentOperator(5)<CR>
nnoremap ;o6 :call PrintCurrentOperator(6)<CR>

" print rosie world
nnoremap ;pw :call PrintRosieWorld()<CR>


