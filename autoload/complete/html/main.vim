let s:menulist = []
let s:cssprops = load#csspropnames()
let s:css_snippets = load#snippets('css')

function! s:complete_internal_css()
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
        return complete#utils#Menu(s:menulist)
	endif
endfun


function! s:complete_fields()
    let filename = expand("%:p")
    let logs = []
    let logfile = complete#django#logfpath()
    let trigger_dict = {}
    for line in readfile(logfile)
        if line =~ filename
            let sl = split(line, ':')
            let html_trigger = sl[1]
            let model_name = sl[2]
            let model_path = sl[3]
            let fields = complete#django#models#fields(model_path, model_name)
            call extend(trigger_dict, {html_trigger: fields}, 'force')
        endif
	endfor
    "searchpair
    let clnum = line('.')
    let [startlnum, endlnum] = str#searchrange('{%\s*for\s\w\+\sin\s.\+\s*%}', '{%\s*endfor\s*%}')
    if startlnum != 0 && endlnum != 0
        let for_tag = getline(startlnum)->matchstr('{%\sfor\s\w\+\sin\s.\+\s%}')
        if !empty(for_tag)
            let for_trigger = getline(startlnum)->matchstr('\(for\s\)\@<=\w\+')
            let in_list = getline(startlnum)->matchstr('\(in\s\)\@<=\w\+')
            for [key, val] in items(trigger_dict)
                if searchpair("{{", "\%#" ,"}}", 'nWz', '', line('.')) && str#pword() =~ for_trigger.'\.$'
                    let fields = get(trigger_dict, in_list, [])
                    call extend(trigger_dict, {html_trigger: fields}, 'force')
                    return complete#func#Menu(fields)
                endif
            endfor
        endif
    else
        for [key, val] in items(trigger_dict)
            if searchpair("{[{%]", "\%#" ,"[%}]}", 'nWz', '', line('.')) && str#pword() =~ key.'\.$'
                let fields = get(trigger_dict, key, [])
                call extend(trigger_dict, {html_trigger: fields}, 'force')
                return complete#func#Menu(fields)
            endif
        endfor
	endif
endfun

function! complete#html#main#func()
    let inside_style_tag = searchpair('<style>', '\%#', '</style>', 'Wbn')
    if inside_style_tag > 0
        return s:complete_internal_css()
    endif
    if &ft == 'htmldjango'
        return s:complete_fields()
    endif
endfun
