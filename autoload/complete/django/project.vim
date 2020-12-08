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

function! s:from_models()
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

function! s:get_inherited_name(trigger)
    let pat_clsname ='\(class\s\w\+(\)\+\(\w\+\)\+\(\.\w\+\)*\():\)\+' 
    let cls_lnum = PrevClasslnum()
    let matched = matchstr(getline(cls_lnum), pat_clsname)
    let trigger = substitute(matched, pat_clsname, '\2', 'ig')
    let module = substitute(matched, pat_clsname, '\3', 'ig')
    if trigger == a:trigger && !empty(module)
        return substitute(module, '\.', '__', '')
    elseif trigger == a:trigger && empty(module)
        return ""
    else
        return "NOTFOUND"
    endif
endfun

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

function! complete#django#project#menus()
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
    elseif s:from_models()
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
    endif

    " Set trigger_byauto; trigger_bypath
    " Scan from previous line to line 1
    " if line contains "from django", then register autoload funcs
    " if line contains "from .models", then register directory path
    for line in range(1, line('.')-1)
        let cline = getline(line)
        if cline =~ 'from django.\+import\s\w\+'
            call extend(trigger_byauto, complete#django#trigger#register(cline, 'autoload'), 'keep')
        elseif cline =~ 'from\s\(django\)\@!\(\w\+\)*\.models\simport'
            " from .models import Pet
            call extend(trigger_bypath, complete#django#trigger#register(cline, 'path'), 'keep')
        endif
    endfor
    
    for [trigger, autofunc] in items(trigger_byauto)
        " Trigger properties
        " admin.|...
        " TODO:
        "if expr =~ '^'.trigger.'\.$'
        "    let props = {autofunc}().props
        "    return complete#popup#menu(props)
        "endif

        " Trigger imported functions
        " path(|...
        if expr =~ trigger.'($\|'.trigger.'(.\+, $'
            call complete#django#trigger#importedfunc(autofunc)
        endif 

        " Tiggers when:
        " name = models.|
        " Or:
        " ^def\s|
        let insideclass = PrevClasslnum()
        if insideclass
            let classline = getline(insideclass)
            let trigger_word = matchstr(classline, '\w\+\(\.\)\@=')
            if empty(trigger_word)
                let clnum = PrevClasslnum()
                " Found prevlnum that contains `class`
                " match trigger_word that inside `()`
                let trigger_word = matchstr(classline, '\((\)\@<=\w\+\()\)\@=')
			endif
            if trigger_word == trigger
                let suffix = s:get_inherited_name(trigger)
                if suffix != "NOTFOUND"
                    let autofunc = autofunc.suffix
                    call complete#django#trigger#inheritance(trigger, autofunc)
                endif
            endif
        endif
	endfor

    " Models: QuerySet API
    for [trigger, fpath] in items(trigger_bypath)
        call complete#django#models#QuerySet(trigger, fpath)
	endfor
endfun
