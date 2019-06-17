""""""""""""""""""" SOAR FUNCTIONS """""""""""""""""""
let g:COMMENTED_SOAR_RULE = 1
let g:UNCOMMENTED_SOAR_RULE = 0

function! GetSoarRuleInfo(start_line_num, commented)
	" Gets information about the soar rule at the given line number
	"   (start_line_num can be anywhere inside the rule)
	" commented is either g:COMMENTED_SOAR_RULE or g:UNCOMMENTED_SOAR_RULE
	"   and determines if it is looking for #'s in front of the rule
	" returns a 3-index array if inside a rule (empty array otherwise)
	" rule_info[0] = rule start line number
	" rule_info[1] = rule end line number
	" rule_info[2] = rule name
	let rule_info = [ -1, -1, "" ] 

	" Search backward until we find a line starting with sp {
	let cur_line_num = a:start_line_num
	while cur_line_num >= 0
		let cur_line = getline(cur_line_num)
		let words = split(cur_line)
		if len(words) > 1 && words[0] == (a:commented ? "#sp" : "sp") && words[1][0] == '{'
			let rule_info[0] = cur_line_num
			let rule_info[2] = strpart(words[1], 1)
			break
		endif
		let cur_line_num = cur_line_num - 1
	endwhile
	if rule_info[0] == -1
		return []
	endif

	" Search forward until the end brace is matched
	let last_line_num = line('$')
	let open_brace_count = 1
	let close_brace_count = 0

	let cur_line_num = rule_info[0] + 1
	while cur_line_num <= last_line_num
		let cur_line = getline(cur_line_num)
		" Count number of open braces
		redir => num_open
			silent execute ":".cur_line_num."s/{//gne"
		redir END
		if len(num_open) > 0
			let open_brace_count = open_brace_count + split(num_open)[0]
		endif

		" Count number of closed braces
		redir => num_closed
			silent execute ":".cur_line_num."s/}//gne"
		redir END
		if len(num_closed) > 0
			let close_brace_count = close_brace_count + split(num_closed)[0]
		endif

		if open_brace_count == close_brace_count
			let rule_info[1] = cur_line_num
			break
		endif
		let cur_line_num = cur_line_num + 1
	endwhile
	if rule_info[1] == -1 || rule_info[1] < a:start_line_num
		return []
	endif

	return rule_info
endfunction

function! GetSoarRuleBody(line_num)
	let rule_info = GetSoarRuleInfo(a:line_num, g:UNCOMMENTED_SOAR_RULE)
	return len(rule_info) >= 2 ? join(getline(rule_info[0], rule_info[1]), "\n")."\n" : ""
endfunction

function! GetCurrentSoarRuleBody()
	return GetSoarRuleBody(line('.'))
endfunction

function! GetSoarRuleName(line_num)
	let rule_info = GetSoarRuleInfo(a:line_num, g:UNCOMMENTED_SOAR_RULE)
	return len(rule_info) > 2 ? rule_info[2] : ""
endfunction

function! GetCurrentSoarRuleName()
	return GetSoarRuleName(line('.'))
endfunction

" Will return the word at the given row/col
"   where a word is considered contiguous alpha-numeric characters, 
"   plus underscore, hyphen, and asterisk
function! GetSoarWord(row, col)
	let valid_char = "[a-zA-Z0-9*_-]"
	let cur_line = getline(a:row)

	" Seek forward on the line until hitting an invalid character
	" (or end of line)
	let end_col = a:col - 1
	let hit_valid = 0
	while end_col <= len(cur_line)
		if match(cur_line[end_col], valid_char) == 0
			let end_col += 1
			let hit_valid = 1
		elseif hit_valid
			break
		else
			let end_col += 1
		endif
	endwhile

	" No valid characters after the cursor position, return none
	if !hit_valid
		return ""
	endif

	" Seek backward on the line until hitting an invalid character
	" (or beginning of line)
	let start_col = end_col - 1
	while start_col >= 0
		if match(cur_line[start_col], valid_char) == 0
			let start_col -= 1
		else
			break
		endif
	endwhile
	let start_col += 1

	return strpart(cur_line, start_col, (end_col - start_col))
endfunction

function! GetCurrentSoarWord()
	return GetSoarWord(line('.'), col('.'))
endfunction

