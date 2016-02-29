function! ember_tools#Init()
  if !filereadable('ember-cli-build.js')
    return
  endif

  setlocal includeexpr=ember_tools#Includeexpr()

  command! -count=0 -nargs=1 -buffer Extract call ember_tools#extract#Run(<line1>, <line2>, <f-args>)
endfunction

function! ember_tools#Includeexpr()
  let callbacks = [
        \ 'ember_tools#gf#RouterRoute',
        \ 'ember_tools#gf#ServiceInjection',
        \ 'ember_tools#gf#ServiceProperty',
        \ 'ember_tools#gf#Model',
        \ 'ember_tools#gf#TemplateComponent',
        \ 'ember_tools#gf#Import',
        \ ]

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
