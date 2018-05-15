""""""""""""""" FUNCTIONS """"""""""""""""""

function! ListSoarTemplates(A,L,P)
	let templatedir = $MY_VIM_DIR."/soar_plugin/templates/"
	let templates = split(globpath(templatedir, '*'), '\n')
	let res = []
	let pattern = "^".a:A
	for template_filename in templates
		let template_name = fnamemodify(template_filename, ':t')
		if template_name =~ pattern
			call add(res, template_name)
		endif
	endfor
	return res
endfunction

" Inserts the given template 
function! InsertSoarTemplate(templateFile)
  execute("r ".$MY_VIM_DIR."/soar_plugin/templates/".a:templateFile)

  let op_name = substitute(expand('%:t'), "\.soar", "", "g")
  execute("%s/__OP__NAME__/".op_name."/g")

  let state_name = expand('%:p:h:t')
  execute("%s/__STATE__NAME__/".state_name."/g")
endfunction

" Will search file for #!# and remove them and go to insert mode
function! FindNextInsert()
	if search("#!#") != 0
	    execute "normal! gg/#!#\<cr>"
	    call feedkeys("c3l")
	endif
endfunction

