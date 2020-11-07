let s:css_snippets = load#snippets('css')
let s:keywords = []
let s:menulist = []
let s:cssprops = load#cssprops()

function! complete#up()
    if pumvisible()
        return "\<Up>"
    endif
    return 'k'
endf

function! complete#down()
    if pumvisible()
        return "\<Down>"
    endif
    return 'j'
endf

function! complete#listing()
    let values = ""
    let before = trim(str#before())

    for val in values(s:css_snippets)
        if val =~ '^'.before
            let values = val
        endif
    endfor

    let listing = split(values, '|')
    let values = listing[1:]
    call complete#Menu(col('.'), values)
    return ''
endf

function! complete#Menu(scol, values)
   call complete(a:scol, a:values) 
   return ''
endf

function! complete#func(findstart, base)
    if a:findstart
        let line = getline('.')
        let start = col('.') -1
        while start > 0 && line[start - 1] =~ '\a'
            let start -= 1
        endwhile
        return start
    else
        let matches = []
        for m in s:menulist
            if m =~ '^'.a:base
                call add(matches, m)
            endif
		endfor
        return matches
    endif
endf

function! complete#onCSSTextChanged()
    let values = ""
    let before = trim(str#before())

    let typed_prop = matchstr(before, '.\+\(:$\)\@=')
    if !empty(typed_prop)
        let i = index(s:cssprops, typed_prop)
        if i >= 0
            for vals in values(s:css_snippets)
                if vals =~ '^'.typed_prop
                    let acvals = split(vals, ':')[1:]
                    let values = acvals
                    let values = join(values)
                endif
            endfor
        endif
	endif

    let s:menulist = split(values, '|')
    if len(s:menulist) >= 1
        call feedkeys("\<C-X>\<C-U>")
	endif
endfun

"----------------------------------------
" trigger clauses
"----------------------------------------
function! AfterDef()
    let lnum = line('.')
    for ln in range(lnum, 1, -1)
        if !empty(getline(ln)->matchstr('\(class\|def\)\s\w\+(.\+):'))
            return 1
        endif
	endfor
    return 0
endfun

function! OnImportSection()
    let lnum = line('.')
    let bfc = str#before_cursor()->matchstr('from django')
    for ln in range(lnum, 1, -1)
        if !AfterDef() && !empty(getline(ln)->matchstr('from django')) && !empty(bfc)
            return 1
        endif
	endfor
    return 0
endfun

function! OnExpression(trigger)
    let bforec = str#before_cursor()
    if bforec =~ '\w\+\s\+=\s\+'.a:trigger.'.$'
        return 1
    else
        return 0
    endif
endfun

function! AwaitParams()
    let bforec = str#before_cursor()
    if bforec =~ '($\|,\s$\|?\w$\|?$'
        return 1
    else
        return 0
    endif
endfun

"----------------------------------------

let s:import_triggers = {}
" TODO: KEEP
function! Menu(list, col=0)
    call complete(col('.')+a:col, a:list)
    return ''
endfun

function! s:trigger_complete()
    let before = str#before_cursor()
    for [trigger, autofunc] in items(s:import_triggers)
        if before =~ trigger.'\.$' && AfterDef()
            try
                " Display properties for triggers
                let props = {autofunc}().props
                return Menu(props)
            catch
			endtry
        endif
        if AwaitParams()
            " matchname: (name = models.)@<=CharField(\()@=
            let pat_methname = '\(\w\+\s\+=\s\+'.trigger.'\.\)\@<=\(\w\+\)\((\)\@='
            let methname = matchstr(before, pat_methname)
            if !empty(methname)
                try
                    let options = {autofunc}().options
                    let props = {autofunc}().props
                catch
                endtry
                " avaliable method parameters
                let meth_param_list = []
                for meth in props
                    if meth.word == methname
                        let meth_param_list = meth.user_data
                    endif
                endfor
                "before -> models.CharField(
                if before =~ '?\w$'
                    let base = matchstr(before, '\w$')
                    let option_list = []
                    if !empty(options)
                        for opt in options
                            if opt.word =~ '^'.base
                                call add(option_list, opt)
                            endif
						endfor
                        return Menu(option_list, -2)
					endif
                elseif before=~ '?$'
                    return Menu(options, -1)
                else
                    return Menu(meth_param_list)
                endif

            endif

            " 'params for imported functions'
            if before =~ trigger.'($\|'.trigger.'(.\+, $'
                let import = {autofunc}()
                if has_key(import, 'params')
                    let param_list = {autofunc}().params
                    return Menu(param_list)
                endif
            endif
        endif
	endfor

    " global functions
    if !empty(trim(before)) && AfterDef()
        if !exists('*'.autofunc)
            return ''
        endif
        let loaded = {autofunc}()
        if has_key(loaded, 'globals')
            let globals = {autofunc}().globals
            let base = split(before)[-1]
            let funlist = []
            for func in globals
                if func.word =~ '^'.base
                    call add(funlist, func)
                endif
            endfor
            return Menu(funlist, -1)
        endif
    endif
endfun

function! s:complete_modules(modules)
    let mpath = substitute(a:modules, '\.', '/', 'g')
    let pathstr = 'autoload/'.mpath
    let gpath = globpath(&rtp, pathstr)
    let dirs = readdir(gpath, {n-> n !~ 'import'})
    if empty(dirs)
        let alfn = substitute(mpath, '/', '#', 'g')
        let importall = alfn.'#'.'import#all'
        let importall = substitute(importall, '##', '#', 'g')
        try
            let importall = {importall}()
            return Menu(importall)
        catch
		endtry
    else
        return Menu(dirs)
    endif
    return ''
endfun

function! complete#onPythonTextChanged()
    if OnImportSection()
        let before = str#before_cursor()
        let django = load#django()
        if before =~ '\.$' && before !~ 'import'
            let modules = matchstr(before, '\(from\s\)\@<=.\+$')
            return s:complete_modules(modules)
        endif

        if before =~ 'import\s$'
            let modules = matchstr(before, '\(from\s\)\@<=.\+\(\simport\s\)\@=') 
            return s:complete_modules(modules)
        endif

        if before =~ 'import.\+,\s$'
            let modules = matchstr(before, '\(from\s\)\@<=.\+\(\simport\s\)\@=') 
            return s:complete_modules(modules)
        endif
    endif

    for line in range(1, line('.')-1)
        let cline = getline(line)
        if cline =~ 'from django.\+import\s\w\+'
            let importid = matchstr(cline, '\(import \)\@<=.\+$')
            let relmod = matchstr(cline, '\(from\s\)\@<=.\+\simport')
            let autoprefix = substitute(relmod, '\.\|\s', '#', 'g')
            if importid =~ ','
                let imports = split(importid, ',\s')
                for imp in imports
                    if imp =~ 'as'
                        " import path as p, include as incl
                        let tg = split(imp, ' as ')
                        let autofunc = autoprefix.'#'.tg[0]
                        let s:import_triggers[tg[1]] = autofunc 
                    else
                        " import path, include
                        let autofunc = autoprefix.'#'.trim(imp)
                        let s:import_triggers[trim(imp)] = autofunc
                    endif
                endfor
            else
                if importid =~ 'as\s\w\+'
                    " import path as p
                    let imp = split(importid, ' as ')
                    let trigger = imp[1]
                    let autofunc = autoprefix.'#'.imp[0]
                    let s:import_triggers[imp[1]] = autofunc
                else
                    " import path
                    let s:import_triggers[importid] = autoprefix.'#'.importid
                endif
            endif
        elseif cline =~ 'from .\w\+'
        endif
    endfor
    call s:trigger_complete()
endfun
function! PopupOpts()
    if pumvisible()
        let win = popup_findinfo()
        call popup_setoptions(win, #{
                            \ borderchars: ['-', '|', '-', '|', '┌', '┐', '┘', '└'],
                            \ close:'click',
                            \})
    endif
endfun
