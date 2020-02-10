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

""""""""""""""""" Soar Plugin Key Mappings """""""""""""""""""

" If you set the global variable enable_soar_plugin_mappings to 0
" the plugin keybindings will be skipped
if !exists('g:enable_soar_plugin_mappings')
	let g:enable_soar_plugin_mappings = 1
endif
if !g:enable_soar_plugin_mappings
	finish
endif

" Execute an arbitrary soar command
nnoremap # :call ExecuteUserSoarCommand()<CR>

" Step 1
nnoremap H :Python step(1)<CR>
" Run 10 dc
nnoremap U :Python step(10)<CR>
" Run # = run x100 
nnoremap ;r1 :Python run_silent(100)<CR>
nnoremap ;r2 :Python run_silent(200)<CR>
nnoremap ;r3 :Python run_silent(300)<CR>
nnoremap ;r4 :Python run_silent(400)<CR>
nnoremap ;r5 :Python run_silent(500)<CR>
nnoremap ;r6 :Python run_silent(600)<CR>
nnoremap ;r7 :Python run_silent(700)<CR>
nnoremap ;r8 :Python run_silent(800)<CR>
nnoremap ;r9 :Python run_silent(900)<CR>
" Run 1000 dc (Bad to run forever, will block all other commands)
nnoremap ;ru :Python run_silent(1000)<CR>
" Run 1 elaboration cycle
nnoremap ;re :Python agent.execute_command("run 1 -e")<CR>

" Run 1000 dc slowly
nnoremap ;rs :Python run_slow(1000)<CR>


" See which rules currently match
nnoremap ;ma :Python agent.execute_command("matches")<CR>

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

