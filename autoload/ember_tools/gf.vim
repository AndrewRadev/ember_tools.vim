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

  if !ember_tools#search#UnderCursor('\%(this\.\|@\)transitionTo\%(Route\)\=[( ][''"]\zs\k\+[''"]')
    return ''
  endif

  let route_path = split(expand('<cword>'), '\.')
  let route_path = map(route_path, 'ember_tools#util#Dasherize(v:val)')

  return s:FindRoute(join(route_path, '/'))
endfunction

function! ember_tools#gf#RenderCall()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('\%(this\.\|@\)render[( ][''"]\zs\k\+[''"]')
    return ''
  endif

  return ember_tools#ExistingTemplateFile('app/templates/'.expand('<cfile>'))
endfunction

function! ember_tools#gf#Controller()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('\%(this\.\|@\)controllerFor[( ][''"]\zs\k\+[''"]')
    return ''
  endif

  let controller_path = split(expand('<cword>'), '\.')
  let controller_path = map(controller_path, 'ember_tools#util#Dasherize(v:val)')

  return s:FindController(join(controller_path, '/'))
endfunction

function! ember_tools#gf#Injection()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('^\s*\k\+:\s*\%(Ember\.\)\=\%(inject\.\)\=\(service\|controller\)(')
    return ''
  endif

  let property = expand('<cword>')
  return s:FindInjection(property)
endfunction

function! ember_tools#gf#InjectedProperty()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('\%(this\.\|@\)get[( ][''"]\zs\k\+[''"]')
    return ''
  endif

  let property = expand('<cword>')
  return s:FindInjection(property)
endfunction

function! ember_tools#gf#Model()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  let model_methods = [
        \ 'adapterFor', 'createRecord', 'deleteRecord', 'findAll', 'findRecord',
        \ 'getReference', 'modelFor', 'peekAll', 'peekRecord', 'pushPayload',
        \ 'query', 'queryRecord', 'serializerFor', 'unloadAll',
        \ 'belongsTo', 'hasMany',
        \ ]

  if !ember_tools#search#UnderCursor('\%('.join(model_methods, '\|').'\)[( ][''"]\zs\k\+[''"]')
    return ''
  endif

  let model_name = expand('<cword>')
  let dasherized_name = ember_tools#util#Dasherize(model_name)

  return ember_tools#ExistingLogicFile('app/models/'.dasherized_name)
endfunction

function! ember_tools#gf#AngleBracketTemplateComponent()
  if !ember_tools#IsTemplateFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('^\s*\%(=\|<\|<\/\)\{}\s*\zs\k\+')
    return ''
  endif

  try
    let dasherized_component_file = ''
    let saved_iskeyword = &iskeyword
    set iskeyword+=:
    set iskeyword-=/

    let angle_bracketed_component_name = expand('<cword>')
    let component_parts = split(angle_bracketed_component_name, '::')
    let dasherized_component_name = join(map(component_parts, 'ember_tools#util#Dasherize(v:val)'), '/')
    let dasherized_component_file = s:FindDasherizedComponent(dasherized_component_name)
  catch
    call ember_tools#util#Debug("[gf] Error while deriving angle-bracketed template " . v:exception)
  finally
    let &iskeyword = saved_iskeyword
    return dasherized_component_file
  endtry
endfunction

function! ember_tools#gf#TemplateComponent()
  if !ember_tools#IsTemplateFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('^\s*\%(=\|{{#\|{{\)\{}\s*\zs\k\+')
    return ''
  endif

  let component_name = expand('<cword>')
  return s:FindDasherizedComponent(component_name)
endfunction

function! ember_tools#gf#TemplatePartial()
  if !ember_tools#IsTemplateFiletype()
    return ''
  endif

  if !ember_tools#search#UnderCursor('^\s*{{\s*partial\s*["'']\zs\k\+["'']')
    return ''
  endif

  let partial_name = expand('<cword>')
  return ember_tools#ExistingTemplateFile('app/templates/'.partial_name)
endfunction

function! ember_tools#gf#Import()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  let current_file     = expand('%')
  let current_file_dir = expand('%:h')

  if exists('*json_decode') && filereadable('package.json')
    let package_json = json_decode(join(readfile('package.json'), "\n"))
  else
    let package_json = {}
  endif

  let real_path = ''

  if package_json != {} &&
        \ has_key(package_json, 'name') &&
        \ expand('<cfile>') =~ '^'.package_json.name.'/'
    " the import starts with the app name
    let real_path = substitute(expand('<cfile>'), '^'.package_json.name.'/', 'app/', '')
  elseif current_file =~ '^.'
    exe 'cd '.current_file_dir
    let absolute_path = expand('<cfile>:p')
    cd -
    let real_path = fnamemodify(absolute_path, ':.')
  endif

  if real_path == ''
    return ''
  endif

  let files = s:Glob(real_path.'.*')

  if len(files) > 0
    return files[0]
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
    " try finding files next to this one
    let result = s:FindLocalActionContainer()
  endif

  if result == ''
    call ember_tools#util#Debug("[gf] Can't find action: ".action_name)
    return ''
  else
    call ember_tools#SetFileOpenCallback(result, 'actions:', '^\s*\zs'.action_name.'\%(:\|(\)')
    return result
  endif
endfunction

function! ember_tools#gf#Property()
  if !ember_tools#IsTemplateFiletype()
    return ''
  endif

  let current_file = expand('%:.')
  let property_name = expand('<cword>')

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
    " no file was found, try something else
    return ''
  endif

  let property_pattern = '^\s*\zs'.property_name.':'
  let property_found_in_file = 0

  " Check if the property really is that file
  for line in readfile(result)
    if line =~ property_pattern
      let property_found_in_file = 1
      break
    endif
  endfor

  if !property_found_in_file
    " we should try something else
    return ''
  endif

  call ember_tools#SetFileOpenCallback(result, property_pattern)
  return result
endfunction

function! ember_tools#gf#ExplicitTemplateName()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  if ember_tools#search#UnderCursor('\%(layoutName\|templateName\):\s\+["'']\zs\f\+["'']') <= 0
    return ''
  endif

  return ember_tools#ExistingTemplateFile('app/templates/'.expand('<cfile>'))
endfunction

function! ember_tools#gf#ExplicitControllerName()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  if ember_tools#search#UnderCursor('controllerName:\s\+["'']\zs\f\+["'']') <= 0
    return ''
  endif

  return ember_tools#ExistingLogicFile('app/controllers/'.expand('<cfile>'))
endfunction

function! ember_tools#gf#ImportedVariable()
  if !ember_tools#IsLogicFiletype()
    return ''
  endif

  " Find a real word this time
  set iskeyword-=.,-,/
  let cword = expand('<cword>')
  set iskeyword+=.,-,/

  if search('^import\_s*'.cword.'\_s*from\_s*[''"]\zs\f\+[''"]', 'c') <= 0
    return ''
  endif

  return ember_tools#gf#Import()
endfunction

function! s:FindInjection(property)
  let property = a:property
  let name = split(property, '\.')[0]
  let injection_pattern = '^\s*'.name.':\s*\%(Ember\.\)\=\%(inject\.\)\=\(service\|controller\)('

  if !search(injection_pattern, 'bcW')
    return ''
  endif

  let injection_line = getline('.')
  let injection_type = substitute(injection_line, injection_pattern.'.*$', '\1', '')

  " Check if an explicit name has been given
  let remainder_of_line = substitute(injection_line, injection_pattern, '', '')
  let explicit_name_pattern = '[''"]\zs\k\+\ze[''"]'

  if remainder_of_line =~ explicit_name_pattern
    let explicit_name = matchstr(remainder_of_line, explicit_name_pattern)
    let entity_name = ember_tools#util#Dasherize(explicit_name)
  else
    let entity_name = ember_tools#util#Dasherize(name)
  endif

  return ember_tools#ExistingLogicFile('app/'.injection_type.'s/'.entity_name)
endfunction

function! s:FindDasherizedComponent(component_name)
  let component_file = s:FindComponentTemplate(a:component_name)
  if component_file == ''
    let component_file = s:FindComponentLogic(a:component_name)
  endif
  if component_file == ''
    echomsg "Can't find component: ".a:component_name
    return ''
  endif
  return component_file
endfunction

function! s:FindComponentLogic(component_name)
  let existing_file = ember_tools#ExistingLogicFile('app/components/'.a:component_name)
  if existing_file != '' | return existing_file | endif

  let existing_file = ember_tools#ExistingLogicFile('app/components/'.a:component_name.'/component')
  if existing_file != '' | return existing_file | endif

  let existing_file = ember_tools#ExistingLogicFile('app/pods/'.a:component_name.'/component')
  if existing_file != '' | return existing_file | endif

  let existing_file = ember_tools#ExistingLogicFile('app/pods/components/'.a:component_name.'/component')
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

  let existing_file = ember_tools#ExistingTemplateFile('app/pods/components/'.a:component_name.'/template')
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

function! s:FindLocalActionContainer()
  let existing_file = ember_tools#ExistingLogicFile('./component')
  if existing_file != '' | return existing_file | endif

  let existing_file = ember_tools#ExistingLogicFile('./controller')
  if existing_file != '' | return existing_file | endif

  let existing_file = ember_tools#ExistingLogicFile('./route')
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
