functio! Htmldjango_append(opener, closer)
    if a:opener == '%'
        let pchar = str#pchar()
        let nchar = str#nchar()
        if pchar == '{' && nchar=="}"
            return '%  %'.move#left(2)
        else
            return a:opener
        endif
    else
        return append#pair(a:opener, a:closer)
    endif
endfunction

function! Htmldjango_BS()
    "if str#prevpair() == '  ' && str#pprevpair() == '%%'
    if str#pchar().str#nchar() == ' ' && str#pchar().str#nchar() == '%%'
        return bs#double()
    endif
    return bs#Backspace()
endf

call map#pairs(['%%'], 'htmldjango')
call map#ifunc({'append':'Htmldjango_append', '<Tab>':'snippet#htmldjango', '<BS>': 'Htmldjango_BS'})
call map#exe()

