function! ember_tools#syntax#MarkPrivateArea()
  " Clear out any previous matches
  call clearmatches()

  " Store the current view, in order to restore it later
  let saved_view = winsaveview()

  " start at the last char in the file and wrap for the
  " first search to find match at start of file
  normal! G$
  let flags = "w"
  while search('^\s*[''"]\=actions[''"]\=:\s*\zs{', flags) > 0
    let flags = "W"

    let start_line = line('.')

    " look for the matching "}"
    normal! %
    let end_line = line('.') - 1
    let function_pattern = '^\s*\zs\%(if\|while\|for\)\@!\k\+\ze\%(:\s*function\)\=\s*([^(]*)\s*{'
    call matchadd('emberAction', '\%>'.start_line.'l'.function_pattern.'\%<'.end_line.'l')
  endwhile

  " We're done highlighting, restore the view to what it was
  call winrestview(saved_view)
endfunction
