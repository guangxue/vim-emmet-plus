"""""""""""""""""""""""""""""""""""""""""""""
" File name : close.vim
" Purpose   : Map right bracket
" For       : closer
""""""""""""""""""""""""""""""""""""""""""""""
function! close#brackets(closer)
    if str#nchar() == a:closer
        return move#right(1)
    endif
    return a:closer
endfunction
