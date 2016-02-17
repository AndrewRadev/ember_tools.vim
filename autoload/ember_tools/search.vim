" function! ember_tools#search#UnderCursor(pattern, flags) {{{2
"
" Searches for a match for the given pattern under the cursor. Returns the
" result of the |search()| call if a match was found, 0 otherwise.
"
" Moves the cursor unless the 'n' flag is given.
"
" The a:flags parameter can include one of "e", "p", "s", "n", which work the
" same way as the built-in |search()| call. Any other flags will be ignored.
"
function! ember_tools#search#UnderCursor(pattern, ...)
  let [match_start, match_end] = call('ember_tools#search#PosUnderCursor', [a:pattern] + a:000)
  if match_start > 0
    return match_start
  else
    return 0
  endif
endfunction

" function! ember_tools#search#PosUnderCursor(pattern, flags) {{{2
"
" Searches for a match for the given pattern under the cursor. Returns the
" start and (end + 1) column positions of the match. If nothing was found,
" returns [0, 0].
"
" Moves the cursor unless the 'n' flag is given.
"
" See ember_tools#search#UnderCursor for the behaviour of a:flags
"
function! ember_tools#search#PosUnderCursor(pattern, ...)
  if a:0 >= 1
    let given_flags = a:1
  else
    let given_flags = ''
  endif

  let lnum        = line('.')
  let col         = col('.')
  let pattern     = a:pattern
  let extra_flags = ''

  " handle any extra flags provided by the user
  for char in ['e', 'p', 's']
    if stridx(given_flags, char) >= 0
      let extra_flags .= char
    endif
  endfor

  try
    call ember_tools#cursors#Push()

    " find the start of the pattern
    call search(pattern, 'bcW', lnum)
    let search_result = search(pattern, 'cW'.extra_flags, lnum)
    if search_result <= 0
      return [0, 0]
    endif
    let match_start = col('.')

    " find the end of the pattern
    call ember_tools#cursors#Push()
    call search(pattern, 'cWe', lnum)
    let match_end = col('.')

    " set the end of the pattern to the next character, or EOL. Extra logic
    " is for multibyte characters.
    normal! l
    if col('.') == match_end
      " no movement, we must be at the end
      let match_end = col('$')
    else
      let match_end = col('.')
    endif
    call ember_tools#cursors#Pop()

    if !s:ColBetween(col, match_start, match_end)
      " then the cursor is not in the pattern
      return [0, 0]
    else
      " a match has been found
      return [match_start, match_end]
    endif
  finally
    if stridx(given_flags, 'n') >= 0
      call ember_tools#cursors#Pop()
    else
      call ember_tools#cursors#Drop()
    endif
  endtry
endfunction

" Checks if the given column is within the given limits.
"
function! s:ColBetween(col, start, end)
  return a:start <= a:col && a:end > a:col
endfunction
