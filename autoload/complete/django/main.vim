function! PrevClasslnum()
    let lnum = line('.')
    for ln in range(lnum-1, 1, -1)
        if !empty(getline(ln)->matchstr('class\s\w\+(.\+):'))
            return ln
        endif
	endfor
    return 0
endfun

function! OnImportSection()
    let lnum = line('.')
    let bfc = str#before_cursor()->matchstr('from django')
    for ln in range(lnum, 1, -1)
        if !PrevClasslnum() && !empty(getline(ln)->matchstr('from django')) && !empty(bfc)
            return 1
        endif
	endfor
    return 0
endfun

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

function! s:find_equal(item, list)
    let matched_list = []
    for item in a:list
        if item.word == a:item
            call add(matched, item)
        endif
	endfor
    return matched_list
endfun

function! s:findstart(list)
    let matched_list = []
    let base = matchstr(str#textahead(), '\w$')
    for item in a:list
        if item.word =~ '^'.base && !empty(base)
            call add(matched, item)
        endif
	endfor
    return matched_list
endfun

function! s:triggers(cline, type)
    let cline = a:cline
    let imported = matchstr(cline, '\(import\s\)\@<=.\+$')
    let froms = matchstr(cline, '\(from\s\)\@<=.\+\simport')
    let load_prefix = substitute(froms, '\.\|\s', '#', 'g')
    let froms_path = substitute(froms, '\simport', '', 'g')
    let froms_path = '/'.substitute(froms_path, '\.\|\s', '\/', 'g').'.py'
    let froms_path = substitute(froms_path, '\/\/', '\/', 'g')

    let trigger_byauto = {}
    let trigger_bypath = {}

    if imported =~ ','
        let imports = split(imported, ',\s')
        for imp in imports
            if imp =~ 'as'
                " import path as p, include as incl
                let tg = split(imp, ' as ')
                if a:type == 'autoload'
                    let autofunc = load_prefix.'#'.tg[0]
                    "let s:import_triggers[tg[1]] = autofunc 
                    let trigger_byauto[tg[1]] = autofunc
                elseif a:type == 'path'
                    let filepath = expand("%:p:h").froms_path.tg[1]
                    "let s:user_models[tg[1]] = expand("%:p:h").froms_path
                    let trigger_bypath[tg[1]] = expand("%:p:h").froms_path
				endif
            else
                if a:type == 'autoload'
                    " import path, include
                    let autofunc = load_prefix.'#'.trim(imp)
                    "let s:import_triggers[trim(imp)] = autofunc
                    let trigger_byauto[trim(imp)] = autofunc
                elseif a:type == 'path'
                    "let s:user_models[trim(imp)] = expand("%:p:h").froms_path
                    let trigger_bypath[trim(imp)] = expand("%:p:h").froms_path
                endif
            endif
        endfor
    else
        if imported =~ 'as\s\w\+'
            " import path as p
            let imp = split(imported, ' as ')
            let trigger = imp[1]
            if a:type == 'autoload'
                let autofunc = load_prefix.'#'.imp[0]
                "let s:import_triggers[imp[1]] = autofunc
                let trigger_byauto[imp[1]] = autofunc
            elseif a:type == 'path'
                "let s:user_models[trigger] = expand("%:p:h").froms_path
                let trigger_bypath[trigger] = expand("%:p:h").froms_path
            endif
        else
            if a:type == 'autoload'
                " import path
                "let s:import_triggers[imported] = load_prefix.'#'.imported
                let trigger_byauto[imported] = load_prefix.'#'.imported
            elseif a:type == 'path'
                "let s:user_models[imported] = expand("%:p:h").froms_path 
                let trigger_bypath[imported] = expand("%:p:h").froms_path
            endif
        endif
    endif

    if a:type == 'autoload'
        return trigger_byauto
    endif
    
    if a:type == 'path'
        return trigger_bypath
    endif
endfun

function! s:__importing(modules)
    let mpath = substitute(a:modules, '\.', '/', 'g')
    let pathstr = 'autoload/'.mpath
    let gpath = globpath(&rtp, pathstr)
    let dirs = readdir(gpath, {n-> n !~ '\.'})
    if empty(dirs)
        let alfn = substitute(mpath, '/', '#', 'g')
        let importall = alfn.'#'.'import#all'
        let importall = substitute(importall, '##', '#', 'g')
        try
            let importall = {importall}()
            return complete#utils#Menu(importall)
        catch
		endtry
    else
        return complete#utils#Menu(dirs)
    endif
    return ''
endfun

"" __main__
fun! complete#django#main#entry()
    let expr = str#expr()
    let trigger_byauto = {}
    let trigger_bypath = {}

    if OnImportSection()
        if expr =~ '\.$' && expr !~ 'import'
            let modules = matchstr(expr, '\(from\s\)\@<=.\+$')
            return s:__importing(modules)
        elseif expr =~ 'import\s$'
            let modules = matchstr(expr, '\(from\s\)\@<=.\+\(\simport\s\)\@=') 
            return s:__importing(modules)
        elseif expr =~ 'import.\+,\s$'
            let modules = matchstr(expr, '\(from\s\)\@<=.\+\(\simport\s\)\@=') 
            return s:__importing(modules)
        endif
    endif

    " Set trigger_byauto; trigger_bypath
    for line in range(1, line('.')-1)
        let cline = getline(line)
        if cline =~ 'from django.\+import\s\w\+'
            call extend(trigger_byauto, s:triggers(cline, 'autoload'), 'keep')
        elseif cline =~ 'from\s\(django\)\@!\(\w\+\)*\.models\simport'
            call extend(trigger_bypath, s:triggers(cline, 'path'), 'keep')
        endif
    endfor
    
    for [trigger, autofunc] in items(trigger_byauto)
        " Trigger properties
        " admin.|...
        " TODO:
        "if expr =~ '^'.trigger.'\.$'
        "    let props = {autofunc}().props
        "    return complete#utils#Menu(props)
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

