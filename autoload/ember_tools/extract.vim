function! ember_tools#extract#Run(start_line, end_line, component_name)
  let start_line     = a:start_line
  let end_line       = a:end_line
  let component_name = split(a:component_name, ' ')[0]
  let base_indent    = indent(start_line)

  if filereadable('app/components/'.component_name.'/template.emblem')
    echoerr 'File "app/components/'.component_name.'/template.emblem" already exists'
    return
  endif

  let partial_lines = []
  for line in getline(start_line, end_line)
    let line = substitute(line, '^\s\{'.base_indent.'}', '', '')
    call add(partial_lines, line)
  endfor

  exe start_line.','.end_line.'delete _'
  call append(start_line - 1, repeat(' ', base_indent).'= '.component_name)
  write

  let component_lines = [
        \ "`import Ember from 'ember';`",
        \ "",
        \ "component = Ember.Component.extend()",
        \ "",
        \ "`export default component;`",
        \ ]

  call mkdir('app/components/'.component_name, 'p')
  call writefile(component_lines, 'app/components/'.component_name.'/component.coffee')
  call writefile(partial_lines, 'app/components/'.component_name.'/template.emblem')

  exe 'split app/components/'.component_name.'/template.emblem'
endfunction
