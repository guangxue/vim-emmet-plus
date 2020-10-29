let s:matched_before = ""
let s:matched_after = ""
let s:lc = 0
let s:ptext = str#ptext()
let s:hd_snippets = load#snippets('htmldjango')
let s:vim_snippets = load#snippets('vim')
let s:css_snippets = load#snippets('css')
    
function! s:get_indent(snippet)
    let c_indent = indent('.')
    let unit = shiftwidth()
    let tabnum = c_indent/unit
    let tabs = repeat("\t", tabnum)
    let snippet = str#sub(a:snippet, "\n", "\n".tabs, 'g')
    return snippet
endfunction

function! snippet#vim()
    let ba_str = str#before_after()
    let snip = ba_str[0]
    let before = ba_str[1]
    let after = ba_str[2]

    if empty(snip)
        return "\<Tab>"
    endif
    
    let clnum = line('.')
    let stopline = clnum + 2
    let [lnum, col] = searchpos('\zs{\a\+}', 'Wz', stopline)
    call cursor(lnum, col)
    let char = getline(lnum)[col-1]
    if char == '{'
        call cursor(lnum, col+1)
        call feedkeys("\<BS>\<ESC>vf}")
    elseif char == "'"
        call cursor(lnum, col+1)
        call feedkeys("\<BS>")
    endif 

    if has_key(s:vim_snippets, snip)
        let snippet = s:vim_snippets[snip]
        let snippet = s:get_indent(snippet)
        call buf#setlines(snippet, before, after, line('.'))
        return buf#cursor('$0')
    else
        return "\<Tab>"
    endif
endf


function! snippet#htmldjango()
    let ba_str = str#before_after()
    let snip = len(ba_str[0]) == 0 ? "" : ba_str[0]
    let before = ba_str[1]
    let after = ba_str[2]
    let beforec = str#before()

    call buf#jumpnext(snip, '\${\d', '$', 'hi')
    if has_key(s:hd_snippets, snip)
        let snippet = s:hd_snippets[snip]
        let snippet = s:get_indent(snippet)
        call buf#setlines(snippet, before, after)
        return buf#cursor('${0}')
    else
        let pipcmd = matchstr(beforec, '\w\+|$')
        if !empty(pipcmd)
            let snip = pipcmd[:-2]
            let snippet = get(s:hd_snippets, snip, '')
            if !empty(snippet)
                let restline = str#after()
                let inqs = matchstr(restline, '.\{-}\("\)\@=')
                let snippet = substitute(snippet, '"', "'", 'g')
                let append_snippet = substitute(snippet, '\${0}', inqs, '')
                let before_idx = len(beforec) - len(pipcmd) - 1
                let newline = beforec[0:before_idx].append_snippet.restline[len(inqs):]
                call setline('.', newline)
                return "\<ESC>"
			endif
		endif
        return expand#abbr()
    endif
endf

function! snippet#css()
    let ba_str = str#before_after()
    let snip = len(ba_str[0]) == 0 ? "" : ba_str[0]
    let before = ba_str[1]
    let after = ba_str[2]
    let tablnum = line('.')
    let scol = col('.')

    call buf#jumpnext(snip, '\${\d:\=', '$', 'hi')
    let snippet = get(s:css_snippets, snip, '')

    if empty(snippet)
        return "\<Tab>"
	endif
    

    if snippet =~ '|'
        let cssvals = split(snippet, ':')
        let propname = cssvals[0]
        let propvals = trim(cssvals[1])
        let values = split(propvals, '|')
        call buf#setlines(propname, before, after, tablnum, 'css')
        call buf#cursor('${0}')
        call feedkeys("\<C-X>\<C-U>")
        return ''
    endif 

    let snippet = s:get_indent(snippet)
    call buf#setlines(snippet, before, after, tablnum, 'css')
    call buf#cursor('${0}')
    return ''
endf
