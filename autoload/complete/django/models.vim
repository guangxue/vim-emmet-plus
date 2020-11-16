"" complete#django#model#main()
function! s:get_managers(fpath)
    echom "fpath =>".a:fpath
endfun

function! s:get_fields(fpath)
    let fdpath = a:fpath
    let fdlist = []
    let usrModel = ""
    for line in readfile(fdpath)
        if line =~ 'class\s\w\+(.\+):'
            let um = matchstr(line, '\(class\s\)\@<=\w\+\((\)\@=')
            if !empty(um)
                let usrModel = um
	        endif
        elseif line =~ '\w\+\..\+Field('
            let fd = matchstr(line, '\w\+\(\s\+=\s\+\w\+\..\+Field(\)\@=')
            if !empty(fd)
                call add(fdlist, usrModel.":".fd)
            endif
        endif
	endfor
    return fdlist
endfun

function! complete#django#model#QuerySet(trigger, fpath)
    let expr = str#expr()
    let trigger = a:trigger
    let fpath = a:fpath

    let cm = django#objects#QuerySet().chainable
    let ms = django#objects#QuerySet().method
    let lk = django#objects#QuerySet().lookup
    let attrs = django#objects#QuerySet().attrs

    if expr =~ 'except\s'.trigger.'\.$'
        return complete#utils#Menu(attrs)
        " pet = Pet.
    elseif expr =~ '\w\+\s\+=\s\+'.trigger.'\.$'
        call s:get_managers(fpath)
    elseif expr =~ '\w\+\s\+=\s\+'.trigger.'\.\w\+\.'
        let lm = split(expr, '\.')[-1]->matchstr('\w\+')
        " TODO: check words after `trigger` is an Manager instance
        let managers = '\w\+'
        if expr =~ '\w\+\s\+=\s\+'.trigger.'\.'.managers.'\.$'
            return complete#utils#Menu(cm+ms)
        endif
        " Chaining methods
        for c in cm
            if c.word == lm && expr =~ ')\.$'
                return complete#utils#Menu(cm+ms)
            endif
        endfor
        " Under current trigger
        for m in cm+ms
            let fields = s:get_fields(fpath)
            let fdlist = []
            for fd in fields
                if fd =~ '^'.trigger
                    call add(fdlist, matchstr(fd, '\(:\)\@<=\w\+'))
                endif
            endfor
            if expr =~ m.word.'($'
                return complete#utils#Menu(fdlist)
            elseif expr =~ "order_by('$"
                return complete#utils#Menu(fdlist)
            endif
            if expr =~ m.word.'(\w\+__$'
                return complete#utils#Menu(lk)
            endif
        endfor
    endif
endfun
