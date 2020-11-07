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

function! s:comment_endtag(clnum)
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
                return ''
            endif
        endif
    endif
    return ''
endfun

function! s:uncomment_tags()
    let [startlnum, endlnum, clnum] = [0, 0, line('.')]
    if str#next2chars() == '<!'
        let tagname = getline('.')->matchstr(s:pat_str)->matchstr(s:pat_opentag)
        " start cursor at open tag `<!--`
        " use startc_searchrange()
        let inline_elements = load#html_inline()
        if index(inline_elements, tagname) >= 0
            let startlnum = clnum
            let endlnum = clnum
        else
            let [startlnum, endlnum] = str#startc_searchrange('<!-- <'.tagname, '</'.tagname.'> -->')
        endif
    elseif str#before_cursor()->matchstr(s:pat_str) =~ '^<!'
        let [startlnum, endlnum] = str#searchrange('<!--', '-->')
    else
        let [startlnum, endlnum] = str#searchindentrange(line('.'))
    endif

    if startlnum !=0 && endlnum != 0
        call s:uncomment_inner(startlnum, endlnum)
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
    let [startlnum, endlnum] = [0, 0]
    let tagname = getline(a:clnum)->matchstr(s:pat_str)->matchstr(s:pat_opentag)
    let inline_elements = load#html_inline()
    "" comment inline-elements
    if str#after_cursor() =~ '^<\w\+'
        "" comment cursor-next-to-tag
        if index(inline_elements, tagname) >= 0
            let startlnum = a:clnum
            let endlnum = a:clnum
        else
            let [startlnum, endlnum] = str#startc_searchrange('<'.tagname, '</'.tagname)
        endif
    elseif str#before_cursor() =~ '\S' && str#after_cursor() =~ '\w\+'
        "" comment cursor-on-text
        let clinestr = getline(a:clnum)->matchstr(s:pat_str)
        "" comment one-line-tag
        if clinestr =~ '^<\w\+' && clinestr =~ '<\/\w\+>$'
            let startlnum = a:clnum
            let endlnum = a:clnum
        else
            "" comment on-text-range
            if index(inline_elements, tagname) >= 0
                let startlnum = a:clnum
                let endlnum = a:clnum
            else
                let [startlnum, endlnum] = str#searchrange('<'.tagname, '</'.tagname.'>')
            endif
        endif
    else
        "" comment nesting tags
        let [startlnum, endlnum] = str#searchindentrange(a:clnum)
        let start_tagname = getline(startlnum)->matchstr(s:pat_opentag)
        let end_tagname = getline(endlnum)->matchstr(s:pat_closetag)
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        " using `vat` to get correct outer startlnum & endlnum as last resort.
        if start_tagname != end_tagname
            let col = col('.')
            let clp = @0
            let mode = mode()
            silent! normal! vataty
            let @0 = clp 
            let @* = clp
            let startlnum = line('.')
            silent! normal! vat
            let endlnum = line('.')
            call cursor(a:clnum, col) 
            if mode == 'i'
                startinsert
            else
                call feedkeys("\<ESC>")
            endif
            
        endif
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
                call setline(startlnum, cm_startl)
                call setline(endlnum, cm_endl)
                return ''
            endif
            if startlnum == endlnum
                let cm_curline = s:comment_lines(a:clnum, a:clnum)
                call setline(a:clnum, cm_curline)
                return ''
            endif
        endif
    endif
    return ''
endfun

function! s:toggle_emptyline(clnum)
    let col = col('.')
    let clp = @0
    let mode = mode()
    silent! normal! vaty
    let @0 = clp 
    let @* = clp
    let startlnum = line('.')
    silent! normal! vat
    let endlnum = line('.')
    call cursor(a:clnum, col) 
    
    if getline(startlnum)->matchstr(s:pat_str) =~ '<!'
        let [uncm_startl, uncm_endl] = s:uncomment_lines(startlnum, endlnum)
        call setline(startlnum, uncm_startl)
        call setline(endlnum, uncm_endl)
    else
        let [cm_startl, cm_endl] = s:comment_lines(startlnum, endlnum)
        call setline(startlnum, cm_startl)
        call setline(endlnum, cm_endl)
    endif

    if mode == 'i'
        startinsert
    else
        call feedkeys("\<ESC>")
    endif
    return ''
endfun

" __main__ "
function! lang#html#toggle_comment()
    let clnum = line('.')
    let clinestr = getline(clnum)->matchstr(s:pat_str)

    if clinestr =~ '^<!' || clinestr =~ '-->'
        return s:uncomment_tags()
    endif

    if clinestr =~ '<\w\+'
        return s:comment_starttag(clnum)
    elseif clinestr =~ '^<\/'
        return s:comment_endtag(clnum)
    elseif empty(clinestr)
        return s:toggle_emptyline(clnum)
    else
        return ''
    endif

endf
