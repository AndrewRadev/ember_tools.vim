function! ember_tools#unpack#Run()
  " TODO (2016-08-07) Multiline imports (look for the closing ; of the line?)
  " TODO (2016-07-06) Nested unpacking:
  "   const { computed, Controller, inject: { service }, observer } = Ember;

  let saved_view = winsaveview()

  if !search('\%(\k\|\.\)\+', 'bc', line('.'))
    return
  endif

  let namespace = expand('<cword>')
  normal! "_df.
  let member = expand('<cword>')

  " Look for an existing unpacking
  if search('const {.*'.member.'.*}\s\+=\s\+'.namespace, 'n')
    " this member of the namespace is already unpacked, nothing to do
    return
  endif

  if search('const {.*}\s\+=\s\+'.namespace)
    " we found an existing unpacking without this member, unpack it here
    let unpacking = getline('.')
    let unpacking = substitute(unpacking,
          \ '\s*}\(\s\+=\s\+'.namespace.'\)',
          \ ', '.member.' } = '.namespace,
          \ 'g')
    call setline('.', unpacking)

    call winrestview(saved_view)
    silent! call repeat#set(":call ember_tools#unpack#Run(0)\<cr>")
    return
  endif

  " if we're here, there's no existing unpacking
  if search('^const {', 'bW')
    " we can add it after the last unpacking
    call append(line('.'), [''])
    normal! j
  elseif search('^import', 'bW')
    " we can add it after the last import
    call append(line('.'), ['', ''])
    normal! jj
  else
    " just add it at the top of the file
    call append(0, ['', ''])
    normal! gg
  endif

  call setline('.', 'const { '.member.' } = '.namespace.';')
  call winrestview(saved_view)
  silent! call repeat#set(":call ember_tools#unpack#Run()\<cr>")
endfunction

function! ember_tools#unpack#Reverse()
  let saved_view = winsaveview()
  let variable = expand('<cword>')

  if searchpair('const {', '', '}\s*=\s*\zs\k\+', 'W') <= 0
    return
  endif

  let prefix = expand('<cword>')

  call search('\<'.variable.'\>', 'bW')

  " Remove variable from const line
  exe 's/,\s*\%#'.variable.'//e'
  exe 's/\%#'.variable.',\=\s*\ze\%(\k\| }\)//e'

  " Handle empty const blocks
  if getline('.') =~ '^const {\s*} ='
    let next_lineno = nextnonblank(line('.') + 1)

    if getline(next_lineno) !~ '^const'
      " it's something other than another const line, let's delete all the
      " whitespace up until that point
      exe line('.').','.(next_lineno - 1).'delete _'
    else
      " just delete this line
      delete _
    endif
  endif

  " Add prefix everywhere
  normal! G$
  let search_flags = "w"
  let variable_pattern = '\%('.prefix.'\.\)\@<!\<'.variable.'\>'

  while search(variable_pattern, search_flags) > 0
    if synIDattr(synID(line('.'), col('.'), 1), 'name') !~ 'String\|Comment'
      exe 'normal! i'.prefix.'.'
      " go back to the search
      call search(variable_pattern)
    endif
    let search_flags = "W"
  endwhile

  call winrestview(saved_view)
endfunction
