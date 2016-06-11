function! ember_tools#extract#Run(start_line, end_line, component_name)
  if !exists('b:ember_root')
    return
  endif

  let saved_cwd = getcwd()
  exe 'cd '.b:ember_root

  try
    let start_line     = a:start_line
    let end_line       = a:end_line
    let component_name = split(a:component_name, ' ')[0]
    let base_indent    = indent(start_line)

    let template_file = 'app/components/'.component_name.'/template.'.ember_tools#TemplateExtension()

    if ember_tools#util#Filereadable(template_file)
      echoerr 'File "'.template_file.'" already exists'
      return
    endif

    let partial_lines = []
    for line in getline(start_line, end_line)
      let line = substitute(line, '^\s\{'.base_indent.'}', '', '')
      call add(partial_lines, line)
    endfor

    exe start_line.','.end_line.'delete _'
    if ember_tools#TemplateFiletype() == 'emblem'
      call append(start_line - 1, repeat(' ', base_indent).'= '.component_name)
    else " handlebars
      call append(start_line - 1, repeat(' ', base_indent).'{{'.component_name.'}}')
    endif

    write

    if ember_tools#LogicFiletype() == 'coffee'
      let component_lines = [
            \ "`import Ember from 'ember';`",
            \ "",
            \ "component = Ember.Component.extend()",
            \ "",
            \ "`export default component;`",
            \ ]

      call mkdir('app/components/'.component_name, 'p')
      call writefile(component_lines, 'app/components/'.component_name.'/component.coffee')
    else " javascript
      let component_lines = [
            \ "import Ember from 'ember';",
            \ "",
            \ "export default Ember.Component.extend({",
            \ "",
            \ "});",
            \ ]

      call mkdir('app/components/'.component_name, 'p')
      call writefile(component_lines, 'app/components/'.component_name.'/component.js')
    endif

    call writefile(partial_lines, template_file)

    exe 'split '.template_file
  finally
    exe 'cd '.saved_cwd
  endtry
endfunction
