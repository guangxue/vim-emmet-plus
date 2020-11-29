" complete#django#inherited

" Example 1: class Model(models.Model):
" autofunc: #models__Model()
" 
" Example 1a: class Model(models.Manager)
" autofunc: #models_Manager()
"
" Example 2: class MRockNRollConfig(AppConfig)
" autofunc: #AppConfig()
"
" Return data from `#autofunc#`
"  `attrs`: attributes
"  `methods`: methods

function! s:__inclass(name)
    let lnum = line('.')
    for ln in range(lnum-1, 1, -1)
        if !empty(getline(ln)->matchstr('class\s'.a:name.'\((.\+)\)*:'))
            return ln
        endif
	endfor
    return 0
endfun

function! s:__optionals(optionals)
    let expr = str#expr()
    if expr =~ '??$'
        return complete#popup#menu(a:optionals, -2)
    elseif expr =~ '??\w\+$'
        let pword = matchstr(expr, '\w\+$')
        let cur = len(pword) + 2
        let pword_list = complete#django#get#foreach_startswith(a:optionals, pword)
        return complete#popup#menu(pword_list, -cur)
    endif
endfun

function! s:__attributes(imported)
    let attr_list = get(a:imported, 'attributes', [])
    let expr = str#expr()
    if expr =~ '^\w\+'
        let pword = matchstr(expr, '\w\+$')
        let cur = len(pword) + 2
        let pword_list = complete#django#get#foreach_startswith(attr_list, pword)
        return complete#popup#menu(pword_list, -cur)
    else
        return s:__optionals(attr_list)
    endif
endfun

function! s:__parameters(imported)
    let option_list = get(a:imported, 'options', [])
    let expr = str#expr()
    if expr =~ '($\|,\s$'
        let subclass_word = matchstr(expr, '\(\.\)\@<=\w\+')
        if !empty(subclass_word)
            let param_list = complete#django#get#array_for(a:imported.subclass, subclass_word)
            return complete#popup#menu(param_list)
        endif
        let method_word = matchstr(expr, '\w\+\((\)\@=')
        if !empty(method_word)
            let param_list = complete#django#get#array_for(a:imported.methods, method_word)
            return complete#popup#menu(param_list)
        endif
    else
        return s:__optionals(option_list)
    endif
endfun

function! complete#django#trigger#register(cline, type)
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
                    let trigger_byauto[tg[1]] = autofunc
                elseif a:type == 'path'
                    let filepath = expand("%:p:h").froms_path.tg[1]
                    let trigger_bypath[tg[1]] = expand("%:p:h").froms_path
				endif
            else
                if a:type == 'autoload'
                    " import path, include
                    let autofunc = load_prefix.'#'.trim(imp)
                    let trigger_byauto[trim(imp)] = autofunc
                elseif a:type == 'path'
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
                let trigger_byauto[imp[1]] = autofunc
            elseif a:type == 'path'
                let trigger_bypath[trigger] = expand("%:p:h").froms_path
            endif
        else
            if a:type == 'autoload'
                " import path
                let trigger_byauto[imported] = load_prefix.'#'.imported
            elseif a:type == 'path'
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

function! complete#django#trigger#importedfunc(autofunc)
    let imported = {a:autofunc}()
    if has_key(imported, 'params')
        let param_list = imported.params
        return complete#popup#menu(param_list)
    endif
endfun

"Tigger when: name = models.|
function! complete#django#trigger#inheritance(trigger, autofunc)
    let expr = str#expr()
    let imported = {a:autofunc}()
    let method_list = get(imported, 'methods', [])
    let subclass_list = get(imported, 'subclass', [])

    " name = models.|
    if expr =~ '^\w\+\s\+=\s\+'.a:trigger.'\.$'
        return complete#popup#menu(subclass_list)
    elseif expr =~ '^\w\+\s\+=\s\+'.a:trigger.'\.\w\+('
        " name = models.CharField(|
        call s:__parameters(imported)
    elseif expr =~ '^def\s'
        if expr =~ '^def\s$'
            call complete#popup#menu(method_list)
        endif
        if expr =~ '($\|,\s$'
            call s:__parameters(imported)
        endif
    elseif s:__inclass('Meta')
        let imported = django#objects#Model__Meta()
        return s:__attributes(imported)
    else
        call s:__attributes(imported)
    endif
endfun
