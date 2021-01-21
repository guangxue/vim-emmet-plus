function! s:underclasslnum()
    let lnum = line('.')
    for ln in range(lnum-1, 1, -1)
        if !empty(getline(ln)->matchstr('class\s\w\+(.\+):'))
            return ln
        endif
	endfor
    return 0
endfun

function! django#getlines#from_django()
    let lnum = line('.')
    let cline = str#beforecursor()->matchstr('from django')
    for ln in range(lnum, 1, -1)
        " Not inside class defination &&
        " previous line matched `from django`
        " current line matched `from django`
        if !s:underclasslnum() && !empty(getline(ln)->matchstr('from django')) && !empty(cline)
            return 1
        endif
	endfor
    return 0
endfun

function! django#getlines#from_models()
    let lnum = line('.')
    let bfc = str#beforecursor()->matchstr('from\s\(django\)\@!\(\w\+\)*\.models\simport')
    for ln in range(lnum, 1, -1)
        if !PrevClasslnum() && !empty(bfc)
            return 1
        endif
	endfor
    return 0
endfun

function! django#getlines#models_fields(fpath)
    let fpath = a:fpath
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

function! django#getlines#model_names(fpath)
    let fpath = a:fpath
    let modelnames = []
    for line in readfile(fpath)
        if line =~ 'class\s\w\+.\+\(:\)\@='
            let model_class = matchstr(line, '\(class\s\)\@<=\w\+\((models.Model):\)\@=')
            if !empty(model_class)
                call add(modelnames, model_class)
	        endif
        endif
	endfor
    return modelnames
endfun

function! django#getlines#forms_names(fpath)
    let fpath = a:fpath
    let formnames = []
    for line in readfile(fpath)
        if line =~ 'class\s\w\+.\+\(:\)\@='
            let form_class = matchstr(line, '\(class\s\)\@<=\w\+\((forms.Form):\)\@=')
            if !empty(form_class)
                call add(formnames, form_class)
	        endif
        endif
	endfor
    return formnames
endfun

function! django#getlines#view_names(fpath)
    let fpath = a:fpath
    let viewnames = []
    for line in readfile(fpath)
        if line =~ 'class\|def\s\w\+.\+\(:\)\@='
            let view_class = matchstr(line, '\(class\s\)\@<=\w\+\((\w\+\.View)\|\(request\):\)\@=')
            if !empty(view_class)
                call add(modelnames, view_class)
	        endif
        endif
	endfor
    return viewnames
endfun

function! django#getlines#manager_names(fpath)
    let fpath = a:fpath
    let modelnames = []
    for line in readfile(fpath)
        if line =~ 'class\s\w\+.\+\(:\)\@='
            let model_class = matchstr(line, '\(class\s\)\@<=\w\+\((models.Manager):\)\@=')
            if !empty(model_class)
                call add(modelnames, model_class)
	        endif
        endif
	endfor
    return modelnames
endfun
