" Dasherize CamelCased word:
" FooBarBaz -> foo-bar-baz
function! ember_tools#util#Dasherize(word)
  let result = ember_tools#util#Lowercase(a:word)
  return substitute(result, '\C\([A-Z]\)', '-\l\1', 'g')
endfunction

" Lowercase first letter of argument:
" Foo -> foo
function! ember_tools#util#Lowercase(word)
  return substitute(a:word, '^\w', '\l\0', 'g')
endfunction

" CamelCase underscored word:
" foo_bar_baz -> fooBarBaz
function! ember_tools#util#CamelCase(word)
  return substitute(a:word, '_\(.\)', '\U\1', 'g')
endfunction

" Underscore CamelCased word:
" FooBarBaz -> foo_bar_baz
function! ember_tools#util#Underscore(word)
  let result = ember_tools#util#Lowercase(a:word)
  return substitute(result, '\C\([A-Z]\)', '_\l\1', 'g')
endfunction

" Wrap the native filereadable() function to provide some debug logging.
function! ember_tools#util#Filereadable(filename)
  call ember_tools#util#Debug(" Checking existence of file: ".a:filename)
  return filereadable(a:filename)
endfunction

function! ember_tools#util#Debug(message)
  if exists('g:ember_tools_debug') && g:ember_tools_debug
    let message = '[ember_tools]'.a:message
    echomsg message
  endif
endfunction
