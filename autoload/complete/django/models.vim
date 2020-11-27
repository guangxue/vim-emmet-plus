"" complete#django#model#main()
let s:field_path = {}
function! complete#django#models#fdpath()
    return s:field_path
endfun

function! s:get_managers(fpath)
    
endfun

function! complete#django#models#fields(fpath, model_name)
    let fdlist = s:get_fields(a:fpath)
    let fields = []
    for fd in fdlist
        if fd =~ '^'.a:model_name
            call add(fields, matchstr(fd, '\(:\)\@<=\w\+'))
        endif
    endfor
    return fields
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
    "-fdlist-
    "Pet:name
    "Pet:submitter
    "Vaccine:name
    return fdlist
endfun

function! complete#django#models#QuerySet(trigger, fpath)
    let expr = str#expr()
    let trigger = a:trigger
    let fpath = a:fpath

    let cm = django#objects#QuerySet().chainable
    let ms = django#objects#QuerySet().method
    let lk = django#objects#QuerySet().lookup
    let attrs = django#objects#QuerySet().attrs

    if expr =~ 'except\s'.trigger.'\.$'
        return complete#func#Menu(attrs)
        " pet = Pet.
    elseif expr =~ '\w\+\s\+=\s\+'.trigger.'\.$'
        call s:get_managers(fpath)
        " pet = Pet.objects.|
    elseif expr =~ '\w\+\s\+=\s\+'.trigger.'\.\w\+\.'
        " pet = Pet.objects.filter().|
        " match: fileter()
        let lm = split(expr, '\.')[-1]->matchstr('\w\+')
        " TODO: check words after `trigger` is an Manager instance
        let managers = '\w\+'
        if expr =~ '\w\+\s\+=\s\+'.trigger.'\.'.managers.'\.$'
            return complete#func#Menu(cm+ms)
        endif
        " chaining methods
        for c in cm
            if c.word == lm && expr =~ ')\.$'
                return complete#func#Menu(cm+ms)
            endif
        endfor
        " chainable methods + methods
        for method in cm+ms
            let html_trigger = matchstr(expr, '^\w\+\(\s\+=\)\@=')
            "NOTE: set global field path
            call extend(s:field_path, {html_trigger: trigger.':'.fpath}, 'force')
            let fields = complete#django#models#fields(fpath, trigger)
            if expr =~ method.word.'($'
                return complete#func#Menu(fields)
            elseif expr =~ "order_by('$"
                return complete#func#Menu(fields)
            endif
            if expr =~ method.word.'(\w\+__$'
                return complete#func#Menu(lk)
            endif
        endfor
    endif
endfun
