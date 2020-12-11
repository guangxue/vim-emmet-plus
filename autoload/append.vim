
function! s:append_quotes(qt, space=0)
    if str#nchar() == a:qt 
        return move#right(1)
    elseif str#ptext_has(a:qt) && str#isalpha(str#pchar()) 
        return a:qt
    elseif str#isalpha(str#pchar()) && a:qt == "'"
        return a:qt
    elseif str#isalpha(str#nchar())
        return a:qt
    elseif str#last2chars() == '``' && a:qt == '`'
        return repeat('`', 4).move#left(3)
    elseif str#last2chars() == '""' && a:qt == '"'
        return repeat('"', 4).move#left(3)
    elseif str#last2chars() == "''" && a:qt == "'"
        return repeat("'", 4).move#left(3)
    else
        if a:space > 0
            return a:qt[0].'  '.a:qt[1].move#left(2)
        endif
        return repeat(a:qt, 2).move#left(1)
    endif
endf

function! s:append_brackets(left, right, space=0)
    if str#nchar() =~ '\w'
        if str#nchar() =~ '[)"]' 
            return a:left.a:right.move#left(1)
        else
            return a:left
        endif
    else
        if a:space > 0
            return a:left.'  '.a:right.move#left(2)
        endif
        return a:left.a:right.move#left(1)
    endif
endf

function! append#brackets(opener, closer, space=0)
    if a:opener == a:closer
        return s:append_quotes(a:opener, a:space)
    endif

    if a:opener != a:closer
        return s:append_brackets(a:opener, a:closer, a:space)
    endif
endfunction
