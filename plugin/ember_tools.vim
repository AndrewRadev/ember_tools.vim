if exists('g:loaded_ember_tools') || &cp
  finish
endif

let g:loaded_ember_tools = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:ember_tools_custom_gf_callbacks')
  let g:ember_tools_custom_gf_callbacks = []
endif

augroup ember_tools
  autocmd!

  autocmd FileType coffee,emblem call ember_tools#Init()
augroup END

let &cpo = s:keepcpo
unlet s:keepcpo
