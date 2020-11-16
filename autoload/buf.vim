let s:tablnum = 0
let s:stoplnum = 0
let s:jumprange = []

function! buf#stopline()
    return s:stoplnum
endf
function! buf#reset_stopline()
    let s:stoplnum = 0
endf
function! buf#setlines(lines, before='', after='', tablnum=0, ft='', mode='')
    let before = a:before
    let after = a:after
    let lines = a:lines
    let s:tablnum = a:tablnum

    let lines = split(lines, '\n')

    if empty(a:mode)
        let lines = split(a:lines, '\n')
        if len(lines) == 1
            let line = before.trim(lines[0]).after
            let s:stoplnum = s:tablnum
            if a:ft == 'css' && line !~ '\${\d:\='
                let line = line . ': ${0};'
            endif
            call setline('.', line)
        else
            let line0 = before.trim(lines[0])
            let eol = lines[-1].after
            let nextlines = lines[1:-2]
            let nextlines = add(nextlines, eol)
            let s:stoplnum = s:tablnum + len(nextlines)
            call setline('.', line0)
            call append('.', nextlines)
        endif
        let s:jumprange = range(s:tablnum, s:stoplnum)
    endif
    if a:mode == 'v'
        if len(lines) == 1
            let line = trim(lines[0])
            call setline('.', line)
        else
            let line0 = trim(lines[0])
            let eol = lines[-1]
            let nextlines = lines[1:-2]
            let nextlines = add(nextlines, eol)
            call setline('.', line0)
            call append('.', nextlines)
        endif
    endif
endf

function! buf#jumpnext(snip, pat, trigger, action)
    if empty(a:snip)
        return "\<Tab>"
    endif

    if index(s:jumprange, s:tablnum) < 0 && s:stoplnum > 0
        let s:stoplnum = 0
    endif
    let [lnum, col] = searchpos(a:pat, 'Wz', s:stoplnum)
    if lnum == 0
        let s:stoplnum = 0
    endif
    call cursor(lnum, col)
    let char = getline(lnum)[col-1]
    if char == a:trigger
        if a:action == 'hi'
            call cursor(lnum, col+1)
            call feedkeys("\<BS>\<ESC>vf}")
        endif
        if a:action == 'del'
            call cursor(lnum, col)
            call feedkeys("\<BS>")
            silent! normal! 4x
        endif
    endif 
endf

function! buf#cursor(caret='')
    if a:caret == '$0'
        let lnum = line('.')
        call cursor(lnum, 1)
        let [lnum, col] = searchpos('$0', 'zW', s:stoplnum)
        call cursor(lnum, col)
        call feedkeys("\<Del>\<Del>")
        return ''
    endif
    if a:caret == '${0}'
        let lnum = line('.')
        call cursor(lnum, 1)
        let [lnum, col] = searchpos('\${0}', 'zW')
        silent! %s/\${0}//g
        call cursor(lnum, col)
        return ''
    endif
endf

function! s:scandir(dir, mod)
    let found_dir = ""
    let mod = a:mod

    for file in readdir(a:dir)
        if file == 'manage.py'
            let found_dir = a:dir
            break
        endif
    endfor
    
    if !empty(found_dir)
        return found_dir
    else
        let mod .=':h'
        return mod
	endif
endfun

function! buf#ftdetect()
    let mod = "%:p:h"
    let found = ""
    let dir = expand(mod)
    let mod = s:scandir(dir, mod)
    while mod =~ ':'
        let hs = str#matchcount(mod, ':h')
        if hs > 6
            break
        endif
        let dir = expand(mod)
        let mod = s:scandir(dir, mod)
    endwhile
    if mod =~ '/'
        let &ft = 'htmldjango'
    endif
endf
