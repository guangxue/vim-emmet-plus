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
        return complete#utils#Menu(a:optionals, -2)
    elseif expr =~ '??\w\+$'
        let pword = matchstr(expr, '\w\+$')
        let cur = len(pword) + 2
        let pword_list = complete#django#get#foreach_startswith(a:optionals, pword)
        return complete#utils#Menu(pword_list, -cur)
    endif
endfun

function! s:__attributes(imported)
    let attr_list = get(a:imported, 'attributes', [])
    let expr = str#expr()
    if expr =~ '^\w\+'
        let pword = matchstr(expr, '\w\+$')
        let cur = len(pword) + 2
        let pword_list = complete#django#get#foreach_startswith(attr_list, pword)
        return complete#utils#Menu(pword_list, -cur)
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
            return complete#utils#Menu(param_list)
        endif
        let method_word = matchstr(expr, '\w\+\((\)\@=')
        if !empty(method_word)
            let param_list = complete#django#get#array_for(a:imported.methods, method_word)
            return complete#utils#Menu(param_list)
        endif
    else
        return s:__optionals(option_list)
    endif
endfun

function! complete#django#trigger#importedfunc(autofunc)
    let imported = {a:autofunc}()
    if has_key(imported, 'params')
        let param_list = imported.params
        return complete#utils#Menu(param_list)
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
        return complete#utils#Menu(subclass_list)
    elseif expr =~ '^\w\+\s\+=\s\+'.a:trigger.'\.\w\+('
        " name = models.CharField(|
        call s:__parameters(imported)
    elseif expr =~ '^def\s'
        if expr =~ '^def\s$'
            call complete#utils#Menu(method_list)
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
