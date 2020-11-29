function! sp#Space()
    if str#pchar().str#nchar() == '{}'
        return repeat(' ', 2).move#left(1)
    else
        return "\<Space>"
    endif
endfunction

