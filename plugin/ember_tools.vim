if exists('g:loaded_ember_tools') || &cp
  finish
endif

let g:loaded_ember_tools = '0.2.0' " version number
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:ember_tools_custom_gf_callbacks')
  let g:ember_tools_custom_gf_callbacks = []
endif

if !exists('g:ember_tools_default_logic_filetype')
  let g:ember_tools_default_logic_filetype = 'javascript'
endif

if !exists('g:ember_tools_default_template_filetype')
  let g:ember_tools_default_template_filetype = 'handlebars'
endif

" possible values: separate-template, component-dir
if !exists('g:ember_tools_extract_behaviour')
  let g:ember_tools_extract_behaviour = 'separate-template'
endif

if !exists('g:ember_tools_highlight_actions')
  let g:ember_tools_highlight_actions = 1
endif

if !exists('g:ember_tools_highlight_actions_on')
  "
  " possible values: "init", "write", "insert-leave",
  "                  "normal-text-changed",  "cursor-hold"
  "
  let g:ember_tools_highlight_actions_on = ['init', 'insert-leave', 'normal-text-changed']
endif

augroup ember_tools
  autocmd!

  autocmd FileType javascript,coffee,handlebars,html.handlebars,emblem
        \ call ember_tools#Init()

  " Override gf if rails sets it after us
  autocmd User Rails
        \ if exists('b:ember_root') |
        \   exe 'cmap <buffer><expr> <Plug><cfile> ember_tools#Includeexpr()' |
        \ endif
augroup END

let &cpo = s:keepcpo
unlet s:keepcpo
