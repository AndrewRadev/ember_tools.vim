" Dasherize CamelCased word:
" FooBarBaz -> foo-bar-baz
function! ember_tools#util#Dasherize(word)
  let result = lib#Lowercase(a:word)
  return substitute(result, '\([A-Z]\)', '-\l\1', 'g')
endfunction
