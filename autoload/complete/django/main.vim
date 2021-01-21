function! PrevClasslnum()
    let lnum = line('.')
    for ln in range(lnum-1, 1, -1)
        if !empty(getline(ln)->matchstr('class\s\w\+(.\+):'))
            return ln
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

function! s:get(dict, key)
    let value = ""
    for [key, val] in items(a:dict)
        if key =~# a:key
            let value = val
        endif
    endfor
    return value
endfun

let s:storagefile = globpath(&rtp, "autoload/django/localstorage.vim")
let s:curr_forms = {}
function complete#django#main#func()
    let django = findfile("manage.py",".;")
    if empty(django)
        return
    elseif django =~ 'manage.py'
        let expr = str#expr()
        let trigger_byauto = {}
        let trigger_bypath = {}
        call complete#django#import#section()
        call extend(trigger_byauto, complete#django#trigger#register()[0], 'force')
        call extend(trigger_bypath, complete#django#trigger#register()[1], 'force')
        " Set trigger rules
        " Parse based on autoload functions
        for [trigger, autofunc] in items(trigger_byauto)
            " Trigger properties
            " admin.|...
            " TODO:
            "if expr =~ '^'.trigger.'\.$'
            "    let props = autofunc}().props
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
        " Trigger: QuerySet API
        " Example: from .models import Blog
        " Trigger: Form API
        " Example: from .forms import NameForm
        let file_content = readfile(s:storagefile)
        for [trigger, fpath] in items(trigger_bypath)
            if expr =~ '\w\+\s\+=\s\+'.trigger && fpath =~ 'models.py'
                return complete#django#models#queryset(trigger, fpath)
            elseif expr =~ '\w\+\s\+=\s\+'.trigger && fpath =~ 'forms.py'
                let form = matchstr(expr, '\w\+\(\s\+\)\@=')
                let insline = '\'.string(form).':'.string(trigger).','
                if index(file_content, insline) < 0
                    call extend(s:curr_forms, {form:trigger}, 'force')
                    call insert(file_content, insline, -1)
                endif
                call writefile(file_content, s:storagefile, 's')
            endif
        endfor
        let mc_forms = extend(django#localstorage#all(), s:curr_forms, 'force')
        for mc in keys(mc_forms)
            if expr=~ mc.'\.$'
                let form_attrs = django#instance#form()
                return complete#popup#menu(form_attrs)
            endif
		endfor
	endif
endfun

