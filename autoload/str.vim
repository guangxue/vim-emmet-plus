function! s:get_char(pos)
   let chars = getline('.')
   let s:col = col('.')-2
   let idx = s:col + (a:pos)
   return [idx, chars[idx]] 
endf

function! str#ppchar()
    return s:get_char(-1)[1]
endf

function! str#pchar()
    return s:get_char(0)[1]
endf

function! str#pidx()
    return s:get_char(0)[0]
endf

function! str#nidx()
    return s:get_char(1)[0]
endf

function! str#nchar()
    return s:get_char(1)[1]
endf

function! str#nnchar()
    return s:get_char(2)[1]
endf

function! str#prev2chars()
    return str#pchar().str#ppchar()
endf

function! str#next2chars()
    return str#nchar().str#nnchar()
endf
function! str#last2chars()
    return str#ppchar().str#pchar()
endfun

function! MatchAll(str, pat)
    let lst = []
    call substitute(a:str, a:pat, '\=add(lst, submatch(0))', 'g')
    return [lst, len(lst)]
endf

function! str#matchall(str, pat)
    return MatchAll(a:str, a:pat)[0]
endf

function! str#matchcount(str, pat)
    return MatchAll(a:str, a:pat)[1]
endf

function! str#qs(...)
    let dq = '"' 
    let sq = "'"
    let coma = ", "
    if a:0 == 2
        if a:1 =~# "^'"
            return dq.a:1.dq.coma.dq.a:2.dq
        else
            return sq.a:1.sq.coma.sq.a:2.sq
        endif
    endif

    if a:0 == 1
        if a:1 =~# "^'"
            return dq.a:1.dq 
        else
            return sq.a:1.sq
        endif
    endif
endf

function! str#wrap_qs(qs)
    return '('.a:qs.')'
endf

function! str#args(...)
    return '('.str#qs(a:0).')'
endf

function! str#isalpha(char)
    let matched = match(a:char, '^\w')
    if strlen(a:char) > 0 && matched == 0
        return 1
    else
        return 0
    endif
endf

function! str#isdigit(char)
    let matched = match(a:char, '^\d\+')
    if strlen(a:char) > 0 && matched == 0
        return 1
    else
        return 0
    endif
endf

" previous text from pchar including leading whitespace
function! str#ptext()
    let pidx = s:get_char(0)[0]
    if pidx < 0
        return ""
    else
        return getline('.')[0:pidx]
    endif
endf

"previous text from ppchar including whitespace
function! str#pptext()
    let ppidx = s:get_char(-1)[0]
    if ppidx <= 0
        return ""
    else
        return getline('.')[0:ppidx]
    endif
endf

function! str#startswith(str, char)
    let str = a:str
    let pat = '^'.a:char
    if str =~# pat
        return 1
    else
        return ''
endf

function! str#sub(str, pat, sub, count='')
    if count == 'g'
        return substitute(a:str, a:pat, a:sub, 'g')
    else
        return substitute(a:str, a:pat, a:sub, '')
    endif
endf

function! str#ptext_has(delim)
    let ptext = trim(str#ptext())
    let matched_index = matchend(ptext, a:delim)
    if matched_index > 0
        return matched_index
    else
        return ""
    endif
endf

function! str#ptext_has_two(ptext, delim)
    let pidx = s:get_char(0)[0]
    let ptext = a:ptext

    let matched_start = match(ptext, a:delim, 0)
    let matched_end = matchend(ptext, a:delim, 0, 2)
    let diff = matched_end - matched_start
    if diff > 1
        return 1
    else
        return ""
    endif
endf

function! str#beforecursor()
    return getline('.')[:str#pidx()]
endfun

function! str#aftercursor()
    return getline('.')[str#nidx():]
endfun

" start from non-whitespace to current cursor position
function! str#expr()
   let line = getline('.') 
   let idx = 0
   for i in range(len(line))
       if line[i] =~ '^\S'
           let idx = i
           break
       endif
   endfor
   return line[idx:str#pidx()]
endfun

function! str#pword()
    let before = str#beforecursor()
    if !empty(before)
        let split_before = split(before, ' ', 1)
        let last_before = get(split_before, -1, v:none)
        let pword = matchstr(last_before, '[0-9_@A-Za-z\.(]\+$')
        return pword
	endif
endfun

" get string before after pword
function! str#pwordlr(pword='')
    "let str = a:str
    let pword = a:pword
    let before = str#beforecursor()
    let ptext = str#ptext()

    let ptext_len = len(ptext)
    let pword_len = len(pword)
    let idx = ptext_len - pword_len
    
    let before_pword = ""
    let after_pword = ""
    if idx != 0
        let before_pword = getline('.')[0:idx-1]
    else
        let before_pword = ""
    endif

    let after_pword = getline('.')[col('.')-1:]
    return [before_pword, after_pword]
endfun

function! str#dots(str)
    return substitute(a:str, '\s', '\.', 'g')
endfun

function! str#inside_pairs()
    let pchar = str#pchar()
    let nchar = str#nchar()
    let usrpairs = "g:".&ft."_pairs"
    
    let pair = pchar.nchar
    let found_idx = -1

    try
        let found_idx = index({usrpairs}, pair)
        if found_idx < 0
            let found_idx = index(g:default_pairs, pair)
        endif
    catch /E121:/
        let found_idx = index(g:default_pairs, pair)
    endtry
    if found_idx >= 0
        return 1
    else
        return ""
    endif
endf

"" range search
function! str#searchrange(start, end)
    return [searchpair(a:start, '\%#', a:end, 'bnW'), searchpair(a:start, '\%#', a:end, 'nW')]
endf

function! str#outer_pair(start, end)
    return searchpair(a:start, '\%#', a:end, 'rcnWz')
endf

function! str#startlnum_for(start, end)
    return searchpair(a:start, '\%#', a:end, 'bnW')
endf

function! str#endlnum_for(start, end)
    return searchpair(a:start, '\%#', a:end, 'nW')
endf

"" outer search
function! str#outersearchrange(start, end)
    return [searchpair(a:start, '\%#', a:end, 'rbnW'), searchpair(a:start, '\%#', a:end, 'rnW')]
endf

"" cursor at |</
function! str#endc_searchrange(start, end)
    return [searchpair(a:start, '\%#', a:end, 'bnW'), searchpair(a:start, '\%#', a:end, 'cnW')]
endf

"" cursor at |<
function! str#startc_searchrange(start, end)
    return [searchpair(a:start, '\%#', a:end, 'bcnW'), searchpair(a:start, '\%#', a:end, 'nW')]
endf

function! str#searchindentrange(clnum)
    let search_indent = (indent(a:clnum) / &sw) - 1
    let [prevlnum, nextlnum] = [a:clnum, a:clnum]
    let [startlnum, endlnum] = [0,0]
    while 1
        if indent(nextlnum) / &sw == search_indent && !empty(getline(nextlnum))
            let endlnum = nextlnum
            break
        endif
        let nextlnum += 1
    endwhile
    while 1
        if indent(prevlnum) / &sw == search_indent && !empty(getline(prevlnum))
            let startlnum = prevlnum
            break
        endif
        let prevlnum -= 1
    endwhile
    return [startlnum, endlnum]
endf

function! str#clearRegs()
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789*/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
endf
