let s:css_snippets = load#snippets('css')
let s:cssprops = load#csspropnames()
let s:menulist = []

function! complete#css#main#menulist()
    return s:menulist
endfun

function! complete#css#main#func()
    let values = ""
    let css_snippets = load#snippets('css')
    let before = trim(str#beforecursor())

    let propname = matchstr(before, '.\+\(:$\)\@=')
    if !empty(propname)
        if index(load#csspropnames(), propname) >= 0
            for vals in values(css_snippets)
                if vals =~ '^'.propname
                    let acvals = split(vals, ':')[1:]
                    let values = acvals
                    let values = join(values)
                endif
            endfor
        endif
	endif

    let menulist = split(values, '|')
    if len(menulist) >= 1
        return complete#popup#menu(menulist)
	endif
endfun
