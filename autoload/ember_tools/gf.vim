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

  if getline('.') !~ '\<resetNamespace: true\>'
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
  endif

  return s:FindRoute(join(route_path, '/'))
endfunction

function! ember_tools#gf#TransitionRoute()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('transitionTo\%(Route\)\=[( ][''"]\zs\k\+[''"]')
    return ''
  endif

  let route_path = split(expand('<cword>'), '\.')
  let route_path = map(route_path, 'ember_tools#util#Dasherize(v:val)')

  return s:FindRoute(join(route_path, '/'))
endfunction

function! ember_tools#gf#Controller()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('controllerFor[( ][''"]\zs\k\+[''"]')
    return ''
  endif

  let controller_path = split(expand('<cword>'), '\.')
  let controller_path = map(controller_path, 'ember_tools#util#Dasherize(v:val)')

  return s:FindController(join(controller_path, '/'))
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
  let component_file = s:FindComponentTemplate(component_name)
  if component_file == ''
    let component_file = s:FindComponentLogic(component_name)
  endif
  if component_file == ''
    echomsg "Can't find component: ".component_name
    return ''
  endif

  return component_file
endfunction

function! ember_tools#gf#Import()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  let current_file     = expand('%')
  let current_file_dir = expand('%:h')

  if current_file =~ '^.'
    exe 'cd '.current_file_dir
    let absolute_path = expand('<cfile>:p')
    cd -
    let files = s:Glob(fnamemodify(absolute_path.'.*', ':.'))

    if len(files) > 0
      return files[0]
    endif
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

  if search('^\s*'.service_name.':\s*Ember\.inject\.service()', 'bcWn')
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

  let existing_file = ember_tools#ExistingTemplateFile('app/pods/'.a:component_name.'/component')
  if existing_file != '' | return existing_file | endif

  return ''
endfunction

function! s:FindComponentTemplate(component_name)
  let existing_file = ember_tools#ExistingTemplateFile('app/templates/components/'.a:component_name)
  if existing_file != '' | return existing_file | endif

  let existing_file = ember_tools#ExistingTemplateFile('app/components/'.a:component_name.'/template')
  if existing_file != '' | return existing_file | endif

  let existing_file = ember_tools#ExistingTemplateFile('app/pods/'.a:component_name.'/template')
  if existing_file != '' | return existing_file | endif

  return ''
endfunction

function! s:FindController(name)
  let existing_file = ember_tools#ExistingLogicFile('app/controllers/'.a:name)
  if existing_file != '' | return existing_file | endif

  let existing_file = ember_tools#ExistingLogicFile('app/pods/'.a:name.'/controller')
  if existing_file != '' | return existing_file | endif

  return ''
endfunction

function! s:FindRoute(name)
  let filename = ember_tools#ExistingLogicFile('app/routes/'.a:name)
  if filename == ''
    let filename = ember_tools#ExistingLogicFile('app/routes/'.a:name.'/index')
  endif
  if filename == ''
    let filename = ember_tools#ExistingLogicFile('app/pods/'.a:name.'/route')
  endif

  return filename
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
    let name = matchstr(a:filename, 'app/pods/\zs\k\+\ze/template\.\%(emblem\|hbs\)')
  endif

  if name == ''
    let name = matchstr(a:filename, 'app/components/\zs\k\+\ze\.\%(coffee\|js\)')
  endif
  if name == ''
    let name = matchstr(a:filename, 'app/components/\zs\k\+\ze/component\.\%(coffee\|js\)')
  endif
  if name == ''
    let name = matchstr(a:filename, 'app/pods/\zs\k\+\ze/component\.\%(coffee\|js\)')
  endif

  return name
endfunction

function! s:ExtractControllerName(filename)
  let name = matchstr(a:filename, 'app/templates/\zs\k\+\ze\.\%(emblem\|hbs\)')

  if name == ''
    let name = matchstr(a:filename, 'app/\%(controllers\|routes\)/\zs\k\+\ze\.\%(coffee\|js\)')
  endif

  if name == ''
    let name = matchstr(a:filename, 'app/pods/\zs\k\+\ze/controller\.\%(coffee\|js\)')
  endif

  return name
endfunction

function! s:Glob(pattern)
  if v:version >= 740
    " glob can return a list
    return glob(a:pattern, 0, 1)
  else
    " we'll have to split by newlines and hope there's no files with newlines
    " in their names
    return split(glob(a:pattern), "\n")
  endif
endfunction
