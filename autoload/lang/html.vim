let s:pat_str ='\zs\S.\+\S\ze' 
let s:pat_opentag = '\(<\)\@<=\w\+'
let s:pat_closetag = '\(<\/\)\@<=\w\+'

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
        if currentl =~ '<!--'
            let currl = substitute(currentl, '<!-- ', '', 'g')
            call setline(i, currl)
        endif
        if currentl =~ '-->'
            let currl = substitute(currentl, ' -->', '', 'g')
            call setline(i, currl)
        endif
	endfor
    return ''
endfun

function! s:comment_tagfrom(tag) abort
    let clnum = line('.')

    if a:tag == 'open'
        let startlnum = 0
        let endlnum = 0
        if str#nchar() == '<' && str#nnchar() != '/'
            let tagname = getline(clnum)->matchstr(s:pat_str)->matchstr(s:pat_opentag)
            " start cursor at open tag `|<\w\+`
            " use startc_search
            let [startlnum, endlnum] = str#startc_searchrange('<'.tagname, '</'.tagname)
        else
            let [startlnum, endlnum] = str#searchrange('<\w\+','</\w\+>')
        endif
        if endlnum != 0
            call s:uncomment_inner(clnum, endlnum-1)
            " if has outer uncommented tag, uncomment it and do nothing.
            if !s:has_outer_uncomment_done()
                if endlnum > clnum
                    let [cm_startl, cm_endl] = s:comment_lines(startlnum, endlnum)
                    if getline(startlnum)->matchstr(s:pat_str) =~ '<!--'
                        let [uncm_startl, uncm_endl] = uncomment_lines(startlnum, endlnum)
                        call setline(startlnum, uncm_startl)
                        call setline(endlnum, uncm_endl)
                        return ''
                    elseif s:sameindent(startlnum, endlnum)
                        call setline(startlnum, cm_startl)
                        call setline(endlnum, cm_endl)
                        return ''
                    endif
                endif
                if endlnum == clnum
                    let cm_curline = s:comment_lines(clnum, clnum)
                    call setline(clnum, cm_curline)
                    return ''
                endif
            endif
        endif
        return ''
    endif

    if a:tag == 'close'
        " cursor at close tag `|</w+>`
        " use endc_search
        let tagname = getline(clnum)->matchstr(s:pat_closetag)
        let [startlnum, endlnum] = str#endc_searchrange('\ze<'.tagname, '<\/'.tagname.'>\zs')
        if startlnum != 0 && endlnum != 0
            call s:uncomment_inner(startlnum, endlnum)
            if !s:has_outer_uncomment_done()
                if startlnum < clnum && s:sameindent(startlnum, endlnum)
                    let [cm_startl, cm_endl] = s:comment_lines(startlnum, endlnum)
                    call setline(startlnum, cm_startl)
                    call setline(endlnum, cm_endl)
                    return ''
                endif
            endif
        endif
        return ''
    endif
endf

function! s:sameindent(startl, endl)
    if indent(a:startl) == indent(a:endl)
        return 1
    else
        return 0
    endif
endf
function! s:uncomment_tags()
    let startlnum =0
    let endlnum = 0
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
endf

function! lang#html#toggle_comment()
    let clinestr = getline('.')->matchstr(s:pat_str)
    if str#next2chars() == '<!' || clinestr =~ '-->$'
        return s:uncomment_tags()
    endif

    let open_tag = matchstr(clinestr, '\(<\)\@<=\w\+')
    if !empty(open_tag)
        return s:comment_tagfrom('open')
	endif
    if empty(open_tag)
        return s:comment_tagfrom('close')
    endif
endf
