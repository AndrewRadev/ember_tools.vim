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

  if !ember_tools#search#UnderCursor('\%(createRecord\|modelFor\)[( ][''"]\zs\k\+[''"]')
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

  if filereadable('app/templates/components/'.component_name.'.emblem')
    return 'app/templates/components/'.component_name.'.emblem'
  elseif filereadable('app/components/'.component_name.'/template.emblem')
    return 'app/components/'.component_name.'/template.emblem'
  else
    echomsg "Can't find component: ".component_name
    return ''
  endif
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
