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

" Set trigger_byauto; trigger_bypath
" Scan from previous line to line 1
" if line contains "from django", then register autoload funcs
" if line contains "from .models;from .forms" then register directory path
function! complete#django#trigger#register()
    let trigger_byauto = {}
    let trigger_bypath = {}
    for line in range(1, line('.')-1)
        let cline = getline(line)
        if cline =~ 'from django.\+import\s\w\+'
            call extend(trigger_byauto, s:parseline(cline, 'autoload'), 'keep')
        elseif cline =~ 'from\s\(django\)\@!\(\w\+\)*\(\.models\|\.forms\)\simport'
            " from .models import Pet
            " from .forms import ContactForm
            call extend(trigger_bypath, s:parseline(cline, 'path'), 'keep')
        endif
    endfor
    return [trigger_byauto, trigger_bypath]
endfun

function! s:parseline(cline, type)
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

function! s:__optionals(optionals)
    let expr = str#expr()
    if expr =~ '?$'
        return complete#popup#menu(a:optionals, -1)
    elseif expr =~ '?\w\+$'
        let pword = matchstr(expr, '\w\+$')
        let cur = len(pword) + 1
        let pword_list = complete#items#startswith(a:optionals, pword)
        return complete#popup#menu(pword_list, -cur)
    endif
endfun

function! s:__attributes(imported)
    let attr_list = get(a:imported, 'attributes', [])
    let expr = str#expr()
    if expr =~ '^\w\+'
        let pword = matchstr(expr, '\w\+$')
        let cur = len(pword) + 2
        let pword_list = complete#items#startswith(attr_list, pword)
        return complete#popup#menu(pword_list, -cur)
    else
        return s:__optionals(attr_list)
    endif
endfun

function! s:__subclass(imported)
    let option_list = get(a:imported, 'options', [])
    if expr =~ '($\|,\s$'
        let subclass_word = matchstr(expr, '\(\.\)\@<=\w\+')
        if !empty(subclass_word)
            let param_list = complete#items#user_data(a:imported.subclass, subclass_word)
            return complete#popup#menu(param_list)
        endif
        let method_word = matchstr(expr, '\w\+\((\)\@=')
        if !empty(method_word)
            let param_list = complete#items#user_data(a:imported.methods, method_word)
            return complete#popup#menu(param_list)
        endif
    elseif expr =~ 'widget\s*=\s*forms\.$'
        let forms_widgets = a:imported.widgets
        return complete#popup#menu(forms_widgets)
    else
        return s:__optionals(option_list)
    endif
endfun

function! s:__methods(method_list)
    call complete#popup#menu(a:method_list)
endfun

function! s:__inside_model_parens(imported, startlnum)
    let option_list = get(a:imported, 'options', [])
    if getline('.') =~ '\s\w$'
        let subclass_word = matchstr(getline(a:startlnum), '\(\.\)\@<=\w\+')
        if !empty(subclass_word)
            let param_list = complete#items#user_data(a:imported.subclass, subclass_word)
            return complete#popup#menu(param_list, -1)
        endif
        let method_word = matchstr(expr, '\w\+\((\)\@=')
        if !empty(method_word)
            let param_list = complete#items#user_data(a:imported.methods, method_word)
            return complete#popup#menu(param_list, -1)
        endif
    elseif getline('.') =~ 'widget\s*=\s*forms\.$'
        let forms_widgets = a:imported.widgets
        return complete#popup#menu(forms_widgets)
    else
        return s:__optionals(option_list)
    endif
endfun

"Tigger when: name = models.|
function! complete#django#trigger#inheritance(trigger, autofunc)
    let expr = str#expr()
    let imported = {a:autofunc}()
    let method_list = get(imported, 'methods', [])
    let subclass_list = get(imported, 'subclass', [])

    let [startlnum, endlnum] = str#searchrange('(',')')
    if startlnum != 0 && endlnum != 0
        let modelstmt = getline(startlnum)->matchstr('\w\+\s\+=\s\+'.a:trigger.'\.\w\+(')
        " name = models.CharField(
        "   |
        " )
        if !empty(modelstmt)
            return s:__inside_model_parens(imported, startlnum)
		endif
    endif

    " name = models.|
    if expr =~ '^\w\+\s\+=\s\+'.a:trigger.'\.$'
        return complete#popup#menu(subclass_list)
    elseif expr =~ '^\w\+\s\+=\s\+'.a:trigger.'\.\w\+('
        " name = models.CharField(|
        call s:__subclass(imported)
    elseif expr =~ '^def\s$'
        call s:__methods(method_list)
    elseif s:__inclass('Meta')
        let imported = django#objects#Model__Meta()
        return s:__attributes(imported)
    else
        call s:__attributes(imported)
    endif
endfun
