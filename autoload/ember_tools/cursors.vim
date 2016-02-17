" In order to make the pattern of saving the cursor and restoring it
" afterwards easier, these functions implement a simple cursor stack. The
" basic usage is:
"
"   call ember_tools#cursors#Push()
"   " Do stuff that move the cursor around
"   call ember_tools#cursors#Pop()
"
" Adds the current cursor position to the cursor stack.
function! ember_tools#cursors#Push()
  if !exists('b:cursor_position_stack')
    let b:cursor_position_stack = []
  endif

  call add(b:cursor_position_stack, getpos('.'))
endfunction

" Restores the cursor to the latest position in the cursor stack, as added
" from the ember_tools#cursors#Push function. Removes the position from the stack.
function! ember_tools#cursors#Pop()
  call setpos('.', remove(b:cursor_position_stack, -1))
endfunction

" Discards the last saved cursor position from the cursor stack.
" Note that if the cursor hasn't been saved at all, this will raise an error.
function! ember_tools#cursors#Drop()
  call remove(b:cursor_position_stack, -1)
endfunction
