let s:pat_str ='\zs\S.\+\S\ze' 
let s:pat_opentag = '\(<\)\@<=\w\+'
let s:pat_closetag = '\(<\/\)\@<=\w\+'

" uncomment lines for specified lines.
function! s:uncomment_lines(startline, endline)
    if a:startline == a:endline
        let subedl = substitute(getline(a:startline), '<!-- ', '', 'g')
        return substitute(subedl, ' -->', '', 'g')
    endif
    let startline = getline(a:startline)
    let uncommented_startline = substitute(startline, '<!-- ', '', 'g')
    let endline = getline(a:endline)
    let uncommented_endline = substitute(endline, ' -->', '', 'g')
    return [uncommented_startline, uncommented_endline]
endfun

function! s:comment_lines(startline, endline)
    if a:startline == a:endline
        let curline = getline(a:startline)
        let curlinestr = matchstr(curline, s:pat_str)
        let commented_curline = substitute(curline, s:pat_str, '<!-- '.curlinestr.' -->', 'g')
        return commented_curline
    endif

    let startline = getline(a:startline)
    let startlinestr = matchstr(startline, s:pat_str)
    let commented_startline = substitute(startline, s:pat_str, '<!-- '.startlinestr, 'g')
    
    let endline = getline(a:endline)
    let endlinestr = matchstr(endline, s:pat_str)
    let commented_endline = substitute(endline, s:pat_str, endlinestr.' -->', 'g')

    return [commented_startline, commented_endline]
endfun

function! s:has_outer_uncomment_done()
    let clnum = line('.')
    let [startlnum, endlnum] = str#outersearchrange('<!--', '-->')
    if startlnum != 0 && endlnum != 0
        if index(range(startlnum, endlnum), clnum)
            let [uncm_startline, uncm_endline] = s:uncomment_lines(startlnum, endlnum)
            call setline(startlnum, uncm_startline)
            call setline(endlnum, uncm_endline)
            return 1
        endif
        return ''
    endif
endfun

function! s:uncomment_inner(startlnum, endlnum)
    let start = a:startlnum
    let max = a:endlnum
    for i in range(start, max)
        let currentl = getline(i)
        if currentl =~ '<!-- <' || currentl =~ '> -->'
            let currl = substitute(currentl, '<!-- ', '', 'g')
            let currl = substitute(currl, ' -->', '', 'g')
            call setline(i, currl)
        endif
	endfor
    return ''
endfun


function! s:sameindent(startl, endl)
    let startindent = indent(a:startl)
    let endindent = indent(a:endl)
    if startindent == 0 && endindent == 0
        return 1
    elseif startindent == endindent
        return 1
    else
        return 0
    endif
endf

function! s:comment_endtag(clnum, ret='')
    " cursor at close tag `|</w+>`
    " use endc_search
    let tagname = getline(a:clnum)->matchstr(s:pat_closetag)
    let [startlnum, endlnum] = str#endc_searchrange('\ze<'.tagname, '<\/'.tagname.'>\zs')
    if startlnum != 0 && endlnum != 0
        if getline(startlnum) =~ '<!-- <' && getline(endlnum) =~ '> -->'
            return s:uncomment_tags()
        endif
        call s:uncomment_inner(startlnum, endlnum)
        if !s:has_outer_uncomment_done()
            if startlnum < a:clnum && s:sameindent(startlnum, endlnum)
                let [cm_startl, cm_endl] = s:comment_lines(startlnum, endlnum)
                call setline(startlnum, cm_startl)
                call setline(endlnum, cm_endl)
                return a:ret
            endif
        endif
    endif
    return a:ret
endfun


"" uncomment tags is a combination of uncomment_lines and setlines
function! s:uncomment_tags()
    let [startlnum, endlnum] = [0, 0]
    if str#next2chars() == '<!'
        let tagname = getline('.')->matchstr(s:pat_str)->matchstr(s:pat_opentag)
        " start cursor at open tag `<!--`
        " use startc_searchrange()
        let [startlnum, endlnum] = str#startc_searchrange('<!-- <'.tagname, '</'.tagname.'> -->')
    else
        let [startlnum, endlnum] = str#searchrange('<!--', '-->')
    endif

    if startlnum !=0 && endlnum != 0
        if startlnum == endlnum
            let uncm_line = s:uncomment_lines(startlnum, endlnum)
            call setline(startlnum, uncm_line)
            return ''
        else
            let [uncm_startlnum, uncm_endlnum] = s:uncomment_lines(startlnum, endlnum)
            call setline(startlnum, uncm_startlnum)
            call setline(endlnum, uncm_endlnum)
            return ''
        endif
    endif
    return ''
endf

function! s:comment_starttag(clnum)
    let [startlnum, endlnum, tagname, inline_elements] = [0, 0, '', []]
    if str#after_cursor() =~ '^<\w\+'
        let tagname = getline(a:clnum)->matchstr(s:pat_str)->matchstr(s:pat_opentag)
        let inline_elements = load#html_inline()
        let [startlnum, endlnum] = str#startc_searchrange('<'.tagname, '</'.tagname)
    else
        let search_indent = (indent(a:clnum) / &sw) - 1
        let [prevlnum, nextlnum] = [a:clnum, a:clnum]
        let [startlnum, endlnum] = [0,0]
        while 1
            if indent(nextlnum) / &sw == search_indent
                let endlnum = nextlnum
                break
            endif
            let nextlnum += 1
        endwhile
        while 1
            if indent(prevlnum) / &sw == search_indent
                let startlnum = prevlnum
                break
            endif
            let prevlnum -= 1
        endwhile
    endif

    if index(inline_elements, tagname) >= 0
        let startlnum = a:clnum
    endif

    if getline(startlnum) =~ '<!-- <' && getline(endlnum) =~ '> -->'
        return s:uncomment_tags()
    endif

    if startlnum != 0 && endlnum != 0
        call s:uncomment_inner(a:clnum, endlnum-1)
        " if has outer uncommented tag, uncomment it and do nothing.
        if !s:has_outer_uncomment_done()
            if endlnum > a:clnum
                let [cm_startl, cm_endl] = s:comment_lines(startlnum, endlnum)
                if s:sameindent(startlnum, endlnum)
                    call setline(startlnum, cm_startl)
                    call setline(endlnum, cm_endl)
                    return ''
                endif
            endif
            if startlnum == a:clnum || endlnum == a:clnum
                let cm_curline = s:comment_lines(a:clnum, a:clnum)
                call setline(a:clnum, cm_curline)
                return ''
            endif
        endif
    endif
    return ''
endfun

" __main__ "
function! lang#html#toggle_comment()
    let clnum = line('.')
    let clinestr = getline(clnum)->matchstr(s:pat_str)

    if str#after_cursor() =~ '^<!' || clinestr =~ '-->'
        return s:uncomment_tags()
    endif

    if clinestr =~ '<\w\+'
        return s:comment_starttag(clnum)
    elseif clinestr =~ '^<\/'
        return s:comment_endtag(clnum)
    else
        return ''
    endif

endf
