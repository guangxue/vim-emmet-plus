let s:cr = "\<CR>"
let s:cro = "\<CR>\<ESC>O"

function! cr#Enter()
    let nchar = str#nchar()
    let pchar = str#pchar()

    if pumvisible()
        return "\<C-y>"
    endif
    if str#inside_pairs()
        return s:cro
    elseif str#ptext_has_two(trim(str#ptext()), '(')
        if str#isalpha(pchar) > 0 || pchar == ' ' || pchar == ','
            return s:cro
        else
            return s:cr
        endif
    elseif pchar == '>' && nchar == '<'
        return s:cro
    else
        return s:cr
    endif
endfunction


