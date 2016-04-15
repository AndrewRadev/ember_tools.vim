function! ember_tools#gf#RouterRoute()
  if expand('%') != 'app/router.coffee'
    return ''
  endif

  let route_pattern = '@route [''"]\zs\k\+[''"]'

  if !ember_tools#search#UnderCursor(route_pattern)
    return ''
  endif

  let route_name = expand('<cword>')
  let route_path = [route_name]

  if getline('.') =~ '\<resetNamespace: true\>'
    return 'app/routes/'.route_name.'.coffee'
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

  return 'app/routes/'.join(route_path, '/').'.coffee'
endfunction

function! ember_tools#gf#ServiceInjection()
  if &filetype != 'coffee'
    return ''
  endif

  if !ember_tools#search#UnderCursor('^\s*\zs\k\+:\s*Ember\.inject\.service()')
    return ''
  endif

  let property = expand('<cword>')
  return s:FindService(property)
endfunction

function! ember_tools#gf#ServiceProperty()
  if &filetype != 'coffee'
    return ''
  endif

  if !ember_tools#search#UnderCursor('@get[( ][''"]\zs\k\+[''"]')
    return ''
  endif

  let property = expand('<cword>')
  return s:FindService(property)
endfunction

function! ember_tools#gf#Model()
  if &filetype != 'coffee'
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

  if filereadable('app/models/'.dasherized_name.'.coffee')
    return 'app/models/'.dasherized_name.'.coffee'
  else
    return ''
  endif
endfunction

function! ember_tools#gf#TemplateComponent()
  if &filetype != 'emblem'
    return ''
  endif

  if !ember_tools#search#UnderCursor('^\s*=\{}\s*\zs\k\+')
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
  if &filetype != 'coffee'
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
  if &filetype != 'emblem'
    return ''
  endif

  if !ember_tools#search#UnderCursor('action\s*[''"]\zs\k\+[''"]')
    return ''
  endif

  let current_file = expand('%:.')
  let action_name = expand('<cword>')

  echomsg current_file

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
    call ember_tools#SetFileOpenCallback(result, 'actions:', '^\s*\zs'.action_name.':')
    return result
  endif
endfunction

function! s:FindService(property)
  let property = a:property
  let service_name = split(property, '\.')[0]
  let dasherized_service_name = ember_tools#util#Dasherize(service_name)

  if search('^\s*'.service_name.':\s*Ember\.inject\.service()', 'bWn') &&
        \ filereadable('app/services/'.dasherized_service_name.'.coffee')
    return 'app/services/'.dasherized_service_name.'.coffee'
  else
    return ''
  endif
endfunction

function! s:FindComponentLogic(component_name)
  if filereadable('app/components/'.a:component_name.'.coffee')
    return 'app/components/'.a:component_name.'.coffee'
  elseif filereadable('app/components/'.a:component_name.'/component.coffee')
    return 'app/components/'.a:component_name.'/component.coffee'
  else
    return ''
  endif
endfunction

function! s:FindController(component_name)
  if filereadable('app/controllers/'.a:component_name.'.coffee')
    return 'app/controllers/'.a:component_name.'.coffee'
  else
    return ''
  endif
endfunction

function! s:FindComponentTemplate(component_name)
  if filereadable('app/templates/components/'.a:component_name.'.emblem')
    return 'app/templates/components/'.a:component_name.'.emblem'
  elseif filereadable('app/components/'.a:component_name.'/template.emblem')
    return 'app/components/'.a:component_name.'/template.emblem'
  else
    return ''
  endif
endfunction

function! s:IsComponentTemplate(filename)
  return
        \ a:filename =~ 'app/templates/components/\k\+\.emblem' ||
        \ a:filename =~ 'app/components/\k\+\/template.emblem'
endfunction

function! s:IsTemplate(filename)
  return a:filename =~ 'app/templates/\k\+\.emblem'
endfunction

function! s:ExtractComponentName(filename)
  let name = matchstr(a:filename, 'app/templates/components/\zs\k\+\ze\.emblem')
  if name == ''
    let name = matchstr(a:filename, 'app/components/\zs\k\+\ze/template\.emblem')
  endif
  if name == ''
    let name = matchstr(a:filename, 'app/components/\zs\k\+\ze\.coffee')
  endif
  if name == ''
    let name = matchstr(a:filename, 'app/components/\zs\k\+\ze/component\.coffee')
  endif

  return name
endfunction

function! s:ExtractControllerName(filename)
  let name = matchstr(a:filename, 'app/templates/\zs\k\+\ze\.emblem')
  if name == ''
    let name = matchstr(a:filename, 'app/\(controllers\|routes\)/\zs\k\+\ze\.coffee')
  endif

  return name
endfunction
