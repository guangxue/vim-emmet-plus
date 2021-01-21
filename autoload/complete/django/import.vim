function! PrevClasslnum()
    let lnum = line('.')
    for ln in range(lnum-1, 1, -1)
        if !empty(getline(ln)->matchstr('class\s\w\+(.\+):'))
            return ln
        endif
	endfor
    return 0
endfun

function! s:from_django()
    let lnum = line('.')
    let cline = str#beforecursor()->matchstr('from django')
    for ln in range(lnum, 1, -1)
        " Not inside class defination &&
        " previous line matched `from django`
        " current line matched `from django`
        if !PrevClasslnum() && !empty(getline(ln)->matchstr('from \(django\|\.\)')) && !empty(cline)
            return 1
        endif
	endfor
    return 0
endfun

function! s:from_modelspy()
    let lnum = line('.')
    let bfc = str#beforecursor()->matchstr('from\s\(django\)\@!\(\w\+\)*\.models\simport')
    for ln in range(lnum, 1, -1)
        if !PrevClasslnum() && !empty(bfc)
            return 1
        endif
	endfor
    return 0
endfun

function! s:from_views()
    let lnum = line('.')
    let bfc = str#beforecursor()->matchstr('from\s\(django\)\@!\(\w\+\)*\.views\simport')
    for ln in range(lnum, 1, -1)
        if !PrevClasslnum() && !empty(bfc)
            return 1
        endif
	endfor
    return 0
endfunc

function! s:from_formspy()
    let lnum = line('.')
    let bfc = str#beforecursor()->matchstr('from\s\(django\)\@!\(\w\+\)*\.forms\simport')
    for ln in range(lnum, 1, -1)
        if !PrevClasslnum() && !empty(bfc)
            return 1
        endif
	endfor
    return 0
endfunc

function! s:import_with_autoload(modules)
    let mpath = substitute(a:modules, '\.', '/', 'g')
    let pathstr = 'autoload/'.mpath
    let gpath = globpath(&rtp, pathstr)
    let dirs = readdir(gpath, {n-> n !~ '\.\|_'})
    if empty(dirs)
        let alfn = substitute(mpath, '/', '#', 'g')
        let importall = alfn.'#'.'import#all'
        let importall = substitute(importall, '##', '#', 'g')
        try
            let importall = {importall}()
            return complete#popup#menu(importall)
        catch
		endtry
    else
        return complete#popup#menu(dirs)
    endif
    return ''
endfun

function! complete#django#import#section()
    let expr = str#expr()
    let trigger_byauto = {}
    let trigger_bypath = {}

    if s:from_django()
        if expr =~ '\.$' && expr !~ 'import'
            let modules = matchstr(expr, '\(from\s\)\@<=.\+$')
            return s:import_with_autoload(modules)
        elseif expr =~ 'import\s$'
            let modules = matchstr(expr, '\(from\s\)\@<=.\+\(\simport\s\)\@=') 
            return s:import_with_autoload(modules)
        elseif expr =~ 'import.\+,\s$'
            let modules = matchstr(expr, '\(from\s\)\@<=.\+\(\simport\s\)\@=') 
            return s:import_with_autoload(modules)
        endif
    elseif s:from_modelspy()
        if expr =~ 'import\s$'
            let model = matchstr(expr, '\(from\s\)\@<=.\+\(\simport\s\)\@=') 
            let model_path = substitute(model, '\.', '\/', 'g')
            let model_path = expand("%:p:h").model_path.'.py'
            let model_names = django#getlines#model_names(model_path)
            return complete#popup#menu(model_names)
        elseif expr =~ 'import.\+,\s$'
            let model = matchstr(expr, '\(from\s\)\@<=.\+\(\simport\s\)\@=') 
            let model_path = substitute(model, '\.', '\/', 'g')
            let model_path = expand("%:p:h").model_path.'.py'
            let model_names = django#getlines#model_names(model_path)
            return complete#popup#menu(model_names)
        endif
    elseif s:from_formspy()
        if expr =~ 'import\s$'
            let forms = matchstr(expr, '\(from\s\)\@<=.\+\(\simport\s\)\@=') 
            let forms_path = substitute(forms, '\.', '\/', 'g')
            let forms_path = expand("%:p:h").forms_path.'.py'
            let forms_names = django#getlines#forms_names(forms_path)
            return complete#popup#menu(forms_names)
        elseif expr =~ 'import.\+,\s$'
            let forms = matchstr(expr, '\(from\s\)\@<=.\+\(\simport\s\)\@=') 
            let forms_path = substitute(forms, '\.', '\/', 'g')
            let forms_path = expand("%:p:h").forms_path.'.py'
            let forms_names = django#getlines#forms_names(forms_path)
            return complete#popup#menu(forms_names)
        endif
        
    endif
endfun
