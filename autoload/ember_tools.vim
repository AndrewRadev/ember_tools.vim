function! ember_tools#Init()
  if !filereadable('ember-cli-build.js')
    return
  endif

  setlocal includeexpr=ember_tools#Includeexpr()

  command! -count=0 -nargs=1 -buffer Extract call ember_tools#extract#Run(<line1>, <line2>, <f-args>)
endfunction

function! ember_tools#Includeexpr()
  let callbacks = []
  call extend(callbacks, g:ember_tools_custom_gf_callbacks)
  call extend(callbacks, [
        \ 'ember_tools#gf#RouterRoute',
        \ 'ember_tools#gf#ServiceInjection',
        \ 'ember_tools#gf#ServiceProperty',
        \ 'ember_tools#gf#Model',
        \ 'ember_tools#gf#TemplateComponent',
        \ 'ember_tools#gf#Import',
        \ 'ember_tools#gf#Action',
        \ ])

  let saved_iskeyword  = &iskeyword

  for callback in callbacks
    try
      set iskeyword+=.,-,/
      call ember_tools#cursors#Push()

      let path = call(callback, [])
      if path != ''
        return path
      endif
    finally
      call ember_tools#cursors#Pop()
      let &iskeyword = saved_iskeyword
    endtry
  endfor

  return expand('<cfile>')
endfunction

function! ember_tools#SetFileOpenCallback(filename, ...)
  let searches = a:000

  augroup ember_tools_file_open_callback
    autocmd!

    echomsg 'autocmd BufEnter '.a:filename.' normal! gg'
    exe 'autocmd BufEnter '.a:filename.' normal! gg'
    for pattern in searches
      echomsg 'autocmd BufEnter '.a:filename.' call search("'.escape(pattern, '"\').'")'
      exe 'autocmd BufEnter '.a:filename.' call search("'.escape(pattern, '"\').'")'
    endfor
    echomsg 'autocmd BufEnter '.a:filename.' call ember_tools#ClearFileOpenCallback()'
    exe 'autocmd BufEnter '.a:filename.' call ember_tools#ClearFileOpenCallback()'
  augroup END
endfunction

function! ember_tools#ClearFileOpenCallback()
  augroup ember_tools_file_open_callback
    autocmd!
  augroup END
endfunction

function! ember_tools#TemplateFiletype()
  if &filetype == 'handlebars' || &filetype == 'emblem'
    return &filetype
  endif

  return g:ember_tools_default_template_filetype
endfunction

function! ember_tools#LogicFiletype()
  if &filetype == 'javascript' || &filetype == 'coffee'
    return &filetype
  endif

  return g:ember_tools_default_logic_filetype
endfunction

function! ember_tools#TemplateExtension()
  if ember_tools#TemplateFiletype() == 'handlebars'
    return 'hbs'
  endif

  if ember_tools#TemplateFiletype() == 'emblem'
    return 'emblem'
  endif
endfunction
