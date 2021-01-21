function! s:closeAngleBrackets()
    if str#expr() =~ '^#include'
        return '<>'.move#left(1)
    else
        return '<'
    endif
endfun

function! s:jumpback()
    if str#pchar().str#nchar() == '()'
        return bs#del().');'.move#left(2)
    elseif str#pchar().str#nchar() == '[]'
        return bs#del().'];'.move#left(2)
    elseif str#pchar().str#nchar() == '{}'
        return bs#del().'};'.move#left(2)
    else
        return ';'
    endif
endfun

inoremap <silent> <buffer> < <C-R>=<SID>closeAngleBrackets()<CR>
inoremap <silent> <buffer> ; <C-R>=<SID>jumpback()<CR>
