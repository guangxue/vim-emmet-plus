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
    let bfc = str#beforecursor()->matchstr('from django')
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

function! s:__importing(modules)
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

"" __main__
fun! complete#django#main#func()
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

