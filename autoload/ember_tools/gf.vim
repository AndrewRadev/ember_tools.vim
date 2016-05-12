function! ember_tools#gf#RouterRoute()
  if expand('%:r') != 'app/router'
    return ''
  endif

  let route_pattern = '\%(this\.\|@\)route\s*(\=\s*[''"]\zs\k\+[''"]'

  if !ember_tools#search#UnderCursor(route_pattern)
    return ''
  endif

  let route_name = expand('<cword>')
  let route_path = [route_name]

  if getline('.') =~ '\<resetNamespace: true\>'
    return 'app/routes/'.route_name.'.'.ember_tools#LogicExtension()
  endif

  " Find any parent routes
  let indent = indent('.')

  while search('^ \{'.(indent - &sw).'}'.route_pattern, 'bW')
    let route = expand('<cword>')
    call insert(route_path, route, 0)
    let indent = indent('.')

    if getline('.') =~ '\<resetNamespace: true\>'
      break
    endif
  endwhile

  return 'app/routes/'.join(route_path, '/').'.'.ember_tools#LogicExtension()
endfunction

function! ember_tools#gf#ServiceInjection()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('^\s*\zs\k\+:\s*Ember\.inject\.service()')
    return ''
  endif

  let property = expand('<cword>')
  return s:FindService(property)
endfunction

function! ember_tools#gf#ServiceProperty()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('get[( ][''"]\zs\k\+[''"]')
    return ''
  endif

  let property = expand('<cword>')
  return s:FindService(property)
endfunction

function! ember_tools#gf#Model()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  let model_methods = [
        \ 'createRecord',
        \ 'modelFor',
        \ 'belongsTo',
        \ 'hasMany'
        \ ]

  if !ember_tools#search#UnderCursor('\%('.join(model_methods, '\|').'\)[( ][''"]\zs\k\+[''"]')
    return ''
  endif

  let model_name = expand('<cword>')
  let dasherized_name = ember_tools#util#Dasherize(model_name)

  return ember_tools#ExistingLogicFile('app/models/'.dasherized_name)
endfunction

function! ember_tools#gf#TemplateComponent()
  if !ember_tools#IsTemplateFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('^\s*\%(=\|{{\)\{}\s*\zs\k\+')
    return ''
  endif

  let component_name = expand('<cword>')
  let component_template = s:FindComponentTemplate(component_name)

  if component_template == ''
    echomsg "Can't find component: ".component_name
    return ''
  endif

  return component_template
endfunction

function! ember_tools#gf#Import()
  if !ember_tools#IsTemplateFiletype()
    return ''
  endif

  let current_file     = expand('%')
  let current_file_dir = expand('%:h')

  if current_file =~ '^.'
    exe 'cd '.current_file_dir
    let absolute_path = expand('<cfile>:p')
    cd -
    return fnamemodify(absolute_path.'.coffee', ':.')
  endif

  return ''
endfunction

function! ember_tools#gf#Action()
  if !ember_tools#IsTemplateFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('\<action\s*[''"]\zs\k\+[''"]')
    return ''
  endif

  let current_file = expand('%:.')
  let action_name = expand('<cword>')

  if s:IsComponentTemplate(current_file)
    let component_name = s:ExtractComponentName(current_file)
    let result = s:FindComponentLogic(component_name)
  elseif s:IsTemplate(current_file)
    let controller_name = s:ExtractControllerName(current_file)
    let result = s:FindController(controller_name)
  else
    let result = ''
  endif

  if result == ''
    echomsg "Can't find action: ".action_name
    return ''
  else
    call ember_tools#SetFileOpenCallback(result, 'actions:', '^\s*\zs'.action_name.'\%(:\|(\)')
    return result
  endif
endfunction

function! s:FindService(property)
  let property = a:property
  let service_name = split(property, '\.')[0]
  let dasherized_service_name = ember_tools#util#Dasherize(service_name)

  if search('^\s*'.service_name.':\s*Ember\.inject\.service()', 'bWn')
    return ember_tools#ExistingLogicFile('app/services/'.dasherized_service_name)
  else
    return ''
  endif
endfunction

function! s:FindComponentLogic(component_name)
  let existing_file = ember_tools#ExistingLogicFile('app/components/'.a:component_name)
  if existing_file != '' | return existing_file | endif

  let existing_file = ember_tools#ExistingLogicFile('app/components/'.a:component_name.'/component')
  if existing_file != '' | return existing_file | endif

  return ''
endfunction

function! s:FindController(component_name)
  return ember_tools#ExistingLogicFile('app/controllers/'.a:component_name)
endfunction

function! s:FindComponentTemplate(component_name)
  let existing_file = ember_tools#ExistingTemplateFile('app/templates/components/'.a:component_name)
  if existing_file != '' | return existing_file | endif

  let existing_file = ember_tools#ExistingTemplateFile('app/components/'.a:component_name.'/template')
  if existing_file != '' | return existing_file | endif

  return ''
endfunction

function! s:IsComponentTemplate(filename)
  return
        \ a:filename =~ 'app/templates/components/\k\+\.\(emblem\|hbs\)' ||
        \ a:filename =~ 'app/components/\k\+\/template.\(emblem\|hbs\)'
endfunction

function! s:IsTemplate(filename)
  return a:filename =~ 'app/templates/\k\+\.\(emblem\|hbs\)'
endfunction

function! s:ExtractComponentName(filename)
  let name = matchstr(a:filename, 'app/templates/components/\zs\k\+\ze\.\%(emblem\|hbs\)')
  if name == ''
    let name = matchstr(a:filename, 'app/components/\zs\k\+\ze/template\.\%(emblem\|hbs\)')
  endif

  if name == ''
    let name = matchstr(a:filename, 'app/components/\zs\k\+\ze\.\%(coffee\|js\)')
  endif
  if name == ''
    let name = matchstr(a:filename, 'app/components/\zs\k\+\ze/component\.\%(coffee\|js\)')
  endif

  return name
endfunction

function! s:ExtractControllerName(filename)
  let name = matchstr(a:filename, 'app/templates/\zs\k\+\ze\.\%(emblem\|hbs\)')
  if name == ''
    let name = matchstr(a:filename, 'app/\%(controllers\|routes\)/\zs\k\+\ze\.\%(coffee\|js\)')
  endif

  return name
endfunction
