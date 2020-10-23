"""""""""""""""""""""""""""""""""""""""""""""
" File name : close.vim
" Purpose   : Map right bracket
" For       : closer
""""""""""""""""""""""""""""""""""""""""""""""
function! close#brackets(closer)
    let nchar = str#nchar()
    let pchar = str#pchar()

    if nchar == a:closer
        return move#right(1)
    endif
    return a:closer
endfunction
