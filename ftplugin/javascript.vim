if g:ember_tools_highlight_actions
  " Define what color the private area will be
  hi def emberAction cterm=underline gui=underline

  augroup ember_tools_actions_highlight
    autocmd!

    if index(g:ember_tools_highlight_actions_on, 'init') >= 0
      " Initial marking
      autocmd BufEnter <buffer> call ember_tools#syntax#MarkPrivateArea()
    endif

    if index(g:ember_tools_highlight_actions_on, 'write') >= 0
      " Mark upon writing
      autocmd BufWrite <buffer> call ember_tools#syntax#MarkPrivateArea()
    endif

    if index(g:ember_tools_highlight_actions_on, 'insert-leave') >= 0
      " Mark when exiting insert mode (doesn't cover normal-mode text changing)
      autocmd InsertLeave <buffer> call ember_tools#syntax#MarkPrivateArea()
    endif

    if index(g:ember_tools_highlight_actions_on, 'normal-text-changed') >= 0
      " Mark when text has changed in normal mode
      autocmd TextChanged <buffer> call ember_tools#syntax#MarkPrivateArea()
    endif

    if index(g:ember_tools_highlight_actions_on, 'cursor-hold') >= 0
      " Mark when not moving the cursor for 'timeoutlen' time
      autocmd CursorHold <buffer> call ember_tools#syntax#MarkPrivateArea()
    endif
  augroup END
endif
