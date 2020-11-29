let s:logfile = complete#django#logfpath()
let s:insert_fields = {}

function! s:log_fields()
    let current_triggers = keys(current_fields)
    let logged_triggers = getlist#fromfile(s:logfile,':', 1)
    let insert_keys = getlist#exclude(logged_triggers, current_triggers)
    let log_fields = {}
    for [key, val] in items(current_fields)
        call extend(log_fields, {key:val}, 'force')
	endfor
    return log_fields
endfun

function! s:html_triggers(context_data)
    let data = a:context_data->matchstr('{\s*\zs.\+\ze\s*}')
    let data_list = join(str#matchall(data, '\w\+.\(:\)\@='))
    let data_list = str#matchall(data_list, '\w\+')
    return data_list
endfun

function! s:logwriter(render_template, context, fdpath)
    let ix = 0
    let line = ''
    for con in str#matchall(a:context, '\w\+')
        if ix % 2 == 0
            "let line = matchstr(a:render_template, '\w\+.html').':'.con.':'
            let line = a:render_template.':'.con.':'
        else
            let fdpath = get(a:fdpath, con, '')
            if !empty(fdpath)
                let line .= fdpath
            else
                let line = ''
			endif
            let loglines = []
            for ll in readfile(s:logfile)
                call add(loglines, ll)
			endfor
            if index(loglines, line) < 0 && !empty(line)
                call writefile([line], s:logfile, 'a')
            endif
        endif
        let ix += 1
	endfor
endfun

function! django#views#parse#saved()
    let fdpath = complete#django#models#fdpath()
    let clnum = 0
    for line in readfile(expand("%:p"))
        let clnum += 1
        if line =~ 'render('
            let render_template = django#render#template(clnum)
            let render_context = django#render#context(clnum)
            "
            if render_context == 'context'
                
            elseif render_context =~ '^\w\+'
                call cursor(clnum, 1)
                let startlnum = search(render_context.' = {', 'bWz')
                let endlnum = search('}', 'Wz', clnum)
                "let context = join(getlist#fromlines(startlnum, endlnum))->matchstr('{\s*\zs.\+\ze\s*}')
                let context = join(getlist#fromlines(startlnum, endlnum))->matchstr('{.\+}')
                call s:logwriter(render_template, context, fdpath)
            elseif render_context =~ '}$'
                let context = render_context->matchstr('{.\+}')
                call s:logwriter(render_template, context, fdpath)
            endif
		endif
    endfor
endfun
