function! ember_tools#Init()
  if ember_tools#util#Filereadable('ember-cli-build.js')
    " then the current directory is the ember root
    let b:ember_root = fnamemodify('.', ':p:h')
  endif

  if !exists('b:ember_root')
    " then let's look for the ember root upwards
    let file = findfile('ember-cli-build.js', '.;')
    if file != ''
      let b:ember_root = fnamemodify(file, ':p:h')
    endif
  endif

  if !exists('b:ember_root')
    return
  endif

  setlocal includeexpr=ember_tools#Includeexpr()

  if ember_tools#IsTemplateFiletype()
    command! -count=0 -nargs=1 -buffer Extract call ember_tools#extract#Run(<line1>, <line2>, <f-args>)
  endif

  if &filetype is 'javascript'
    command! -buffer Unpack call ember_tools#unpack#Run()
    command! -buffer Inline call ember_tools#unpack#Reverse()
  end
endfunction

function! ember_tools#Includeexpr()
  if !exists('b:ember_root')
    return ''
  endif

  let callbacks = []
  call extend(callbacks, g:ember_tools_custom_gf_callbacks)
  call extend(callbacks, [
        \ 'ember_tools#gf#RouterRoute',
        \ 'ember_tools#gf#TransitionRoute',
        \ 'ember_tools#gf#Controller',
        \ 'ember_tools#gf#Action',
        \ 'ember_tools#gf#Property',
        \ 'ember_tools#gf#Injection',
        \ 'ember_tools#gf#InjectedProperty',
        \ 'ember_tools#gf#Model',
        \ 'ember_tools#gf#TemplateComponent',
        \ 'ember_tools#gf#Import',
        \ ])

  let saved_iskeyword  = &iskeyword
  let saved_cwd = getcwd()
  let found_file = ''

  for callback in callbacks
    try
      exe 'cd '.b:ember_root
      set iskeyword+=.,-,/
      call ember_tools#cursors#Push()

      let path = call(callback, [])
      if path != ''
        let found_file = path
      endif
    finally
      call ember_tools#cursors#Pop()
      let &iskeyword = saved_iskeyword
      exe 'cd '.saved_cwd
    endtry

    if found_file != ''
      let absolutized_file = simplify(b:ember_root.'/'.found_file)
      let relativized_file = fnamemodify(absolutized_file, ':~:.')

      if findfile(relativized_file) != ''
        return relativized_file
      else
        " Seems like Vim has some issues with the path changing due to the
        " "cd". If the relativized version doesn't work, just return the
        " absolute path.
        return absolutized_file
      endif
    endif
  endfor

  return expand('<cfile>')
endfunction

function! ember_tools#SetFileOpenCallback(filename, ...)
  let searches = a:000
  let filename = fnamemodify(a:filename, ':p')

  augroup ember_tools_file_open_callback
    autocmd!

    exe 'autocmd BufEnter '.filename.' normal! gg'
    for pattern in searches
      exe 'autocmd BufEnter '.filename.' call search("'.escape(pattern, '"\').'")'
    endfor
    exe 'autocmd BufEnter '.filename.' call ember_tools#ClearFileOpenCallback()'
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
  if ember_tools#TemplateFiletype() =~ 'handlebars'
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
  if ember_tools#util#Filereadable(file_prefix.'.emblem') | return file_prefix.'.emblem' | endif
  if ember_tools#util#Filereadable(file_prefix.'.hbs')    | return file_prefix.'.hbs'    | endif
  return ''
endfunction

function! ember_tools#ExistingLogicFile(file_prefix)
  let file_prefix = a:file_prefix
  if ember_tools#util#Filereadable(file_prefix.'.coffee') | return file_prefix.'.coffee' | endif
  if ember_tools#util#Filereadable(file_prefix.'.js')     | return file_prefix.'.js'     | endif
  return ''
endfunction
