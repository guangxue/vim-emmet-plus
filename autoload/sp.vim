function! sp#Space()

    if str#prevpair() == '{}'
        return repeat(' ', 2).move#left(1)
    else
        return "\<Space>"
    endif
endfunction

