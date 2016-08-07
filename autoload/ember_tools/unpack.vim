function! ember_tools#unpack#Run(visual)
  " TODO (2016-08-07) Multiline imports (look for the closing ; of the line?)
  " TODO (2016-08-07) Visual mode support
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
  silent! call repeat#set(":call ember_tools#unpack#Run(0)\<cr>")
endfunction

function! ember_tools#unpack#Reverse(visual)
  " code
endfunction
