let s:field_path = {}

function! complete#django#models#fdpath()
    return s:field_path
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

function! s:get_managers(model, path)
    let mdl_mgrs = complete#django#find#manager_names(a:model, a:path)
    let mgrs = get(mdl_mgrs, a:model)+['objects']
    return mgrs
endfun

function! complete#django#models#queryset(model, path)
    let expr = str#expr()
    " method not return QuerySet object
    let chain_methds = django#objects#QuerySet().chainable
    let method = django#objects#QuerySet().method
    let lookups = django#objects#QuerySet().lookup
    "blogs = Blogs.objects.|
    let attrs = django#objects#QuerySet().attrs
    if expr =~ 'except\s'.a:model.'\.$'
        return complete#popup#menu(attrs)
        " pet = Pet.
    elseif expr =~ a:model.'\.$'
        let mgrs = s:get_managers(a:model, a:path)
        return complete#popup#menu(mgrs)
    elseif expr =~ a:model.'\.\w\+\.'
        let mgrdot = matchstr(expr, '\w\+\.$')
        let ablechain = matchstr(expr, '\w\+(.*)\.$')
        if !empty(mgrdot)
            let mdl_mgrs = complete#django#find#manager_names(a:model, a:path)
            let mgrs = get(mdl_mgrs, a:model)+['objects']
            let expr_mgr = matchstr(expr, '\w\+\(\.$\)\@=')
            if index(mgrs, expr_mgr) >= 0
                return complete#popup#menu(chain_methds+method)
            endif
        elseif !empty(ablechain)
            let meth_name = ablechain->matchstr('\w\+')
            for chain in chain_methds
                if chain.word == meth_name
                    return complete#popup#menu(chain_methds+method)
                endif
            endfor
        elseif expr =~ '\w\+($'
            let html_trigger = matchstr(expr, '^\w\+\(\s\+=\)\@=')
            let expr_meth = matchstr(expr, '\w\+\(($\)\@=')
            "NOTE: set global field path
            call extend(s:field_path, {html_trigger: a:model.':'.a:path}, 'force')
            let fields = complete#django#models#fields(a:path, a:model)
            for meth in chain_methds+method
                if meth.word == expr_meth
                    return complete#popup#menu(fields)
                endif
			endfor
        elseif expr =~ '\w\+(\w\+__$'
            return complete#popup#menu(lookups)
        endif
    endif
endfun
