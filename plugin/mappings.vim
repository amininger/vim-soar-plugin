""""""""""""""""" Soar Plugin Commands """""""""""""""""""

""" util.vim """

" Looks for <dir>_source.soar in the same directory
" and appends a line sourcing the current soar file
command! -nargs=0 AddFileToSource :call AddFileToSoarSource()

""" debugger.vim """

" Commands for using the soar debugger
command! -nargs=? -complete=file OpenDebugger :call OpenSoarDebugger(<f-args>)
command! -nargs=0 CloseDebugger :Python close_debugger()
command! -nargs=0 ResetDebugger :Python reset_debugger()
command! -nargs=0 RosieDebugger :call OpenRosieDebugger()

" Source the current file into the running soar agent (debugger.vim)
command! -nargs=0 SourceCurrentFile :call ExecuteSoarCommand("source ".expand('%:p'))

" Source a specified file into the running soar agent (debugger.vim)
command! -nargs=1 -complete=file SourceSoarFile :call SourceSoarFile(<f-args>)

" Inserts a soar template into the current file
command! -nargs=1 -complete=customlist,ListSoarTemplates InsertTemplate :call InsertSoarTemplate(<f-args>)

""""""""""""""""" Soar Plugin Key Mappings """""""""""""""""""

" If you set the global variable disable_soar_plugin_mappings
" the following keybindings will be skipped
if exists('g:disable_soar_plugin_mappings')
	finish
endif

"""""""""""""" parsing.vim """""""""""""""""

" delete production
nnoremap ;dp :call DeleteCurrentSoarRule()<CR>
" yank production (to vim buffer)
nnoremap ;yp :let @" = GetCurrentSoarRuleBody()<CR>
" yank rule name (to vim buffer)
nnoremap ;yr :let @" = GetStrippedCurrentWord()<CR>
" copy production (to clipboard)
nnoremap ;cp :let @+ = GetCurrentSoarRuleBody()<CR>
" copy rule name (to clipboard)
nnoremap ;cr :let @+ = GetStrippedCurrentWord()<CR>

"""""""""""""""" templates.vim """"""""""""""""""

" Searches for the next occurence of #!# and replaces it
" (Used to navigate an inserted soar template)
nnoremap <C-P> :call FindNextInsert()<CR>
inoremap <C-P> <ESC>:call FindNextInsert()<CR>

"""""""""""" debugger.vim """"""""""""""""""""

" Execute an arbitrary soar command
nnoremap # :call ExecuteUserSoarCommand()<CR>

nnoremap H :Python step(1)<CR>
nnoremap U :Python step(10)<CR>
" Run 1 elaboration cycle
nnoremap ;re :Python agent.execute_command("run 1 -e")<CR>

" See which rules currently match
nnoremap ;ma :Python agent.execute_command("matches")<CR>

" source production
nnoremap ;sp :call ExecuteSoarCommand(GetCurrentSoarRuleBody())<CR>
" matches production
nnoremap ;mp :call ExecuteSoarCommand("matches ".GetCurrentSoarRuleName())<CR>
" excise production
nnoremap ;ep :call ExecuteSoarCommand("excise ".GetCurrentSoarRuleName())<CR>

" print rule by name
nnoremap ;pr :call ExecuteSoarCommand("p ".GetStrippedCurrentWord())<CR>
" matches rule name
nnoremap ;mr :call ExecuteSoarCommand("matches ".GetStrippedCurrentWord())<CR>
" excise rule name
nnoremap ;er :call ExecuteSoarCommand("excise ".GetStrippedCurrentWord())<CR>

" print wmes
nnoremap ;p1 :<C-U>call ExecuteSoarCommand("p ".GetStrippedCurrentWord())<CR>
nnoremap ;p2 :<C-U>call ExecuteSoarCommand("p ".GetStrippedCurrentWord()." -d 2")<CR>
nnoremap ;p3 :<C-U>call ExecuteSoarCommand("p ".GetStrippedCurrentWord()." -d 3")<CR>
nnoremap ;p4 :<C-U>call ExecuteSoarCommand("p ".GetStrippedCurrentWord()." -d 4")<CR>
nnoremap ;p5 :<C-U>call ExecuteSoarCommand("p ".GetStrippedCurrentWord()." -d 5")<CR>
nnoremap ;p6 :<C-U>call ExecuteSoarCommand("p ".GetStrippedCurrentWord()." -d 6")<CR>
nnoremap ;p7 :<C-U>call ExecuteSoarCommand("p ".GetStrippedCurrentWord()." -d 7")<CR>
nnoremap ;p8 :<C-U>call ExecuteSoarCommand("p ".GetStrippedCurrentWord()." -d 8")<CR>
nnoremap ;p9 :<C-U>call ExecuteSoarCommand("p ".GetStrippedCurrentWord()." -d 9")<CR>

