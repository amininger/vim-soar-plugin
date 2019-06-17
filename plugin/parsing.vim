""""""""""""""""""" SOAR FUNCTIONS """""""""""""""""""


" GetSoarProductionInfo(line_num, commented)
"	Gets information about the soar production at the given line number
" 	  (line_num can be anywhere inside the production)
" 	  If no line_num is given, uses the current cursor position
" 	if commented is given and equals 1, this will look for #'s in front
"
" 	returns a 3-index array if inside a production (empty array otherwise)
" 	  prod_info[0] = production start line number
" 	  prod_info[1] = production end line number
" 	  prod_info[2] = production name
function! GetSoarProductionInfo(...)
	let line_num = a:0 > 0 ? a:1 : line('.')
	let commented = a:0 > 1 ? a:2 : 0
	let prod_info = [ -1, -1, "" ] 

	" Search backward until we find a line starting with sp {
	let cur_line_num = line_num
	while cur_line_num >= 0
		let cur_line = getline(cur_line_num)
		let words = split(cur_line)
		if len(words) > 1 && words[0] == (commented ? "#sp" : "sp") && words[1][0] == '{'
			let prod_info[0] = cur_line_num
			let prod_info[2] = strpart(words[1], 1)
			break
		endif
		let cur_line_num = cur_line_num - 1
	endwhile
	if prod_info[0] == -1
		return []
	endif

	" Search forward until the end brace is matched
	let last_line_num = line('$')
	let open_brace_count = 1
	let close_brace_count = 0

	let cur_line_num = prod_info[0] + 1
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
			let prod_info[1] = cur_line_num
			break
		endif
		let cur_line_num = cur_line_num + 1
	endwhile
	if prod_info[1] == -1 || prod_info[1] < line_num
		return []
	endif

	return prod_info
endfunction

" GetSoarProductionBody(line_num)
"   Returns the production containing the given line number 
"     as a single string (with newlines)
"   If no line_num is given, it uses the current cursor position
function! GetSoarProductionBody(...)
	let line_num = a:0 > 0 ? a:1 : line('.')
	let prod_info = GetSoarProductionInfo(line_num)
	return len(prod_info) >= 2 ? join(getline(prod_info[0], prod_info[1]), "\n")."\n" : ""
endfunction

" GetSoarProductionName(line_num)
"   Returns the name of the production containing the given line
"   (can be anywhere inside the production)
"   If no line_num is given, it uses the current cursor position
function! GetSoarProductionName(...)
	let line_num = a:0 > 0 ? a:1 : line('.')
	let prod_info = GetSoarProductionInfo(line_num)
	return len(prod_info) > 2 ? prod_info[2] : ""
endfunction

" GetSoarWord(row, col)
"   Will return the word at the given row/col
"     where a word is considered contiguous alpha-numeric characters, 
"     plus underscore, hyphen, and asterisk
"   If no row/column is given, it uses the current cursor position
function! GetSoarWord(...)
	let row = a:0 > 0 ? a:1 : line('.')
	let col = a:0 > 1 ? a:2 : col('.')

	let valid_char = "[a-zA-Z0-9*_-]"
	let cur_line = getline(row)

	" Seek forward on the line until hitting an invalid character
	" (or end of line)
	let end_col = col - 1
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

