function! ember_tools#Init()
  if !filereadable('ember-cli-build.js')
    return
  endif

  setlocal includeexpr=ember_tools#Includeexpr()
endfunction

" TODO (2016-02-16) Improve search under cursor, make it work with \zs
function! ember_tools#Includeexpr()
  let current_file     = expand('%')
  let current_file_dir = expand('%:h')
  let saved_iskeyword  = &iskeyword

  try
    set iskeyword+=.,-,/

    if &filetype == 'coffee'
      if current_file == 'app/router.coffee'
        if ember_tools#search#UnderCursor('@route [''"]\zs\k\+[''"]')
          let route_name = expand('<cword>')
          return s:FindRouteFile(route_name)
        endif
      endif

      if ember_tools#search#UnderCursor('^\s*\zs\k\+:\s*Ember\.inject\.service()')
        let property = expand('<cword>')
        return s:FindService(property)
      endif

      if ember_tools#search#UnderCursor('@get([''"]\zs\k\+[''"]')
        let property = expand('<cword>')
        return s:FindService(property)
      endif
    endif

    if &filetype == 'emblem'
      if ember_tools#search#UnderCursor('^\s*=\{}\s*\zs\k\+')
        let component_name = expand('<cword>')
        return s:FindComponentFile(component_name)
      endif
    endif

    if current_file =~ '^.'
      exe 'cd '.current_file_dir
      let absolute_path = expand('<cfile>:p')
      cd -
      return fnamemodify(absolute_path.'.coffee', ':.')
    endif

    return current_file
  finally
    let &iskeyword = saved_iskeyword
  endtry
endfunction

function! s:FindComponentFile(component_name)
  let component_name = a:component_name

  if filereadable('app/components/'.component_name.'.coffee')
    return 'app/components/'.component_name.'.coffee'
  elseif filereadable('app/components/'.component_name.'/component.coffee')
    return 'app/components/'.component_name.'/component.coffee'
  else
    echoerr "Can't find component: ".component_name
    return ''
  endif
endfunction

function! s:FindRouteFile(route_name)
  let route_name = a:route_name
  let route_path = [route_name]
  let route_pattern = '@route [''"]\zs\k\+[''"]'

  " Find any parent routes
  let indent = indent('.')

  call ember_tools#cursors#Push()
  while search('^ \{'.(indent - &sw).'}'.route_pattern, 'bW')
    let route = expand('<cword>')
    call insert(route_path, route, 0)
    let indent = indent('.')
  endwhile
  call ember_tools#cursors#Pop()

  return 'app/routes/'.join(route_path, '/').'.coffee'
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
