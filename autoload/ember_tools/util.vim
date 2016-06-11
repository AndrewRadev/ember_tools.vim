" Dasherize CamelCased word:
" FooBarBaz -> foo-bar-baz
function! ember_tools#util#Dasherize(word)
  let result = ember_tools#util#Lowercase(a:word)
  return substitute(result, '\([A-Z]\)', '-\l\1', 'g')
endfunction

" Lowercase first letter of argument:
" Foo -> foo
function! ember_tools#util#Lowercase(word)
  return substitute(a:word, '^\w', '\l\0', 'g')
endfunction

" Wrap the native filereadable() function to provide some debug logging.
function! ember_tools#util#Filereadable(filename)
  if exists('g:ember_tools_debug')
    echomsg "Checking existence of file: ".a:filename
  endif
  return filereadable(a:filename)
endfunction
