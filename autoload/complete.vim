let s:css_snippets = load#snippets('css')
let s:keywords = []
let s:menulist = []
let s:cssprops = load#cssprops()

function! complete#up()
    if pumvisible()
        return "\<Up>"
    endif
    return 'k'
endf

function! complete#down()
    if pumvisible()
        return "\<Down>"
    endif
    return 'j'
endf

function! complete#listing()
    let values = ""
    let before = trim(str#before())

    for val in values(s:css_snippets)
        if val =~ '^'.before
            let values = val
        endif
    endfor

    let listing = split(values, '|')
    let values = listing[1:]
    call complete#Menu(col('.'), values)
    return ''
endf

function! complete#Menu(scol, values)
   call complete(a:scol, a:values) 
   return ''
endf

function! complete#func(findstart, base)
    if a:findstart
        let line = getline('.')
        let start = col('.') -1
        while start > 0 && line[start - 1] =~ '\a'
            let start -= 1
        endwhile
        return start
    else
        let matches = []
        for m in s:menulist
            if m =~ '^'.a:base
                call add(matches, m)
            endif
		endfor
        return matches
    endif
endf

function! complete#onCSSTextChanged()
    let values = ""
    let before = trim(str#before())

    let typed_prop = matchstr(before, '.\+\(:$\)\@=')
    if !empty(typed_prop)
        let i = index(s:cssprops, typed_prop)
        if i >= 0
            for vals in values(s:css_snippets)
                if vals =~ '^'.typed_prop
                    let acvals = split(vals, ':')[1:]
                    let values = acvals
                    let values = join(values)
                endif
            endfor
        endif
	endif

    let s:menulist = split(values, '|')
    if len(s:menulist) >= 1
        call feedkeys("\<C-X>\<C-U>")
	endif
endfun
