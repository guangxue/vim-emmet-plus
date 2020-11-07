"""""""""""""""""""""""""""""""""""""""""""""
" Filename : python.vim
""""""""""""""""""""""""""""""""""""""""""""""
setlocal expandtab
setlocal shiftwidth=4
set completefunc=complete#func
let g:pyindent_open_paren = 'shiftwidth()/shiftwidth'

function! s:is_fstr()
    if (str#ppchar() == 'f' && str#pchar() == '"') || (str#ppchar()=='f' && str#pchar()=="'")
        return 1
    else
        return ""
    endif
endf
function! s:is_rstr()
    if (str#ppchar() == 'f' && str#pchar() == '"') || (str#ppchar()=='f' && str#pchar()=="'")
        return 1
    else
        return ""
    endif
endf

function! PyAppend(opener, closer)
    let line = trim(getline('.'), ' ', 0)
    let matched = match(line, '^\(def\s\w\+\)\|^\(class\s\w\+\)')
    let ld = a:opener
    let rd = a:closer
    if matched == 0
        return ld.rd.move#left(2)
    endif
    if len(rd) > 1
        let rd = rd[0]
    endif
    return append#brackets(ld, rd)
endf

function! PyBackspace()
    let ppchar = str#ppchar()
    let pchar = str#pchar()
    let nnchar = str#nnchar()
    let nchar = str#nchar()
    
    if s:is_fstr() || s:is_rstr()
        return bs#fstr()
    elseif nnchar == ":" && str#pchar() == '('
        return bs#def()
    else
        return bs#Backspace()
    endif
endfunction


call map#pairs(['():'], 'python')
call map#ifunc({'append':'PyAppend','<BS>':'PyBackspace', 'feature': {'k':'complete#up()', 'j':'complete#down()'}})
call map#exe()
