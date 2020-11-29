function! complete#popup#menu(list, col=0)
    call complete(col('.')+a:col, a:list)
    return ''
endfun

function! complete#popup#upkey()
    if pumvisible()
        return "\<Up>"
    endif
    return 'k'
endf

function! complete#popup#downkey()
    if pumvisible()
        return "\<Down>"
    endif
    return 'j'
endf

function! complete#popup#listing()
    let values = ""
    let before = trim(str#before())

    for val in values(s:css_snippets)
        if val =~ '^'.before
            let values = val
        endif
    endfor

    let listing = split(values, '|')
    let values = listing[1:]
    call complete#popup#menu(col('.'), values)
    return ''
endfun

function! complete#popup#func(findstart, base)
    if a:findstart
        let line = getline('.')
        let start = col('.') -1
        while start > 0 && line[start - 1] =~ '\a'
            let start -= 1
        endwhile
        return start
    else
        let matches = []
        for m in complete#css#main#menulist()
            if m =~ '^'.a:base
                call add(matches, m)
            endif
		endfor
        return matches
    endif
endf
