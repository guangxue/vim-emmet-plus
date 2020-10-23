"====================================================================================
" vim-emmet-expand : An emmet-like plugin for vim, comes with auto pairs, snippet
"                  : expand, triggered by `Tab`.
" Last Change      : 23 Oct 2020
" Maintainer       : guangxue <contact.guangxue@gmail.com>
" Version          : v0.1
" License          : MIT
"====================================================================================
    
let s:save_cpo = &cpoptions
set cpoptions&vim

if !exists('g:expand_vimscript')
    let g:expand_vimscript = 0
endif

call map#pairs(['()', '{}', '[]', '<>', '""', "''", '``'], 'default')
call map#ifunc({
\   'append':'append#brackets',
\   'close':'close#brackets',
\   '<CR>':'cr#Enter',
\   '<BS>':'bs#Backspace',
\   '<Space>':'sp#Space',
\   'feature':{',':'move#inside()'}
\})
call map#vfunc({'<Tab>': 'wrap#abbr'})
call map#exe()


set completefunc=complete#css
set completeopt=menuone,noinsert
augroup completecss
    autocmd!
    autocmd TextChangedI *.css,*.html call complete#typing()
augroup END

let &cpoptions = s:save_cpo
unlet s:save_cpo

