function! s:template_dir()
    let current_dir = expand("%:p:h")
    set path=**;current_dir
    let template_dir = finddir("templates")
    if template_dir == 'templates'
        let template_dir = expand("%:p:h").'/'.template_dir
    elseif template_dir =~ '^\a'
        let template_dir = current_dir.'/'.template_dir
    endif
    return template_dir.'/'
endfun

function! s:split_params(render_params)
    let render_template = a:render_params->matchstr('\(\w\+\/\)*\w\+\.html')
    let render_template = s:template_dir().render_template
    if a:render_params =~ '{'
        return [render_template, a:render_params->matchstr('{.\+}')]
    else
        let get_context = split(a:render_params, ',')
        return [render_template, get(get_context, 2, '')]
    endif
endfun

function! s:parse_params(clnum)
    call cursor(a:clnum, 1)
    let endlnum  = search(')$', 'zW')
    if endlnum > a:clnum
        let lines = getlist#fromlines(a:clnum, endlnum)
        let render_params = join(lines, '')->matchstr('(\zs.\+\ze)')->substitute('\(,\s\)', ',', 'g')
        return s:split_params(render_params)
    elseif a:clnum == endlnum
        let render_params = getline(a:clnum)->matchstr('(\zs.\+\ze)')->substitute('\(,\s\)', ',', 'g')
        return s:split_params(render_params)
    endif
endfun

function! django#render#template(clnum)
    return s:parse_params(a:clnum)[0]
endfun

function! django#render#context(clnum)
    return s:parse_params(a:clnum)[1]
endfun
