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
        \ 'ember_tools#gf#Action',
        \ 'ember_tools#gf#ServiceInjection',
        \ 'ember_tools#gf#ServiceProperty',
        \ 'ember_tools#gf#Model',
        \ 'ember_tools#gf#TemplateComponent',
        \ 'ember_tools#gf#Import',
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
  if &filetype =~ 'handlebars' || &filetype == 'emblem'
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

function! ember_tools#IsLogicFiletype()
  return index(['coffee', 'javascript'], &filetype) >= 0
endfunction

function! ember_tools#IsTemplateFiletype()
  if &filetype == 'emblem'     | return 1 | endif
  if &filetype =~ 'handlebars' | return 1 | endif
  return 0
endfunction

function! ember_tools#TemplateExtension()
  if ember_tools#TemplateFiletype() == 'handlebars'
    return 'hbs'
  endif

  if ember_tools#TemplateFiletype() == 'emblem'
    return 'emblem'
  endif
endfunction

function! ember_tools#LogicExtension()
  if ember_tools#LogicFiletype() == 'javascript'
    return 'js'
  endif

  return ember_tools#LogicFiletype()
endfunction

function! ember_tools#ExistingTemplateFile(file_prefix)
  let file_prefix = a:file_prefix
  if filereadable(file_prefix.'.emblem') | return file_prefix.'.emblem' | endif
  if filereadable(file_prefix.'.hbs')    | return file_prefix.'.hbs'    | endif
  return ''
endfunction

function! ember_tools#ExistingLogicFile(file_prefix)
  let file_prefix = a:file_prefix
  if filereadable(file_prefix.'.coffee') | return file_prefix.'.coffee' | endif
  if filereadable(file_prefix.'.js')     | return file_prefix.'.js'     | endif
  return ''
endfunction
