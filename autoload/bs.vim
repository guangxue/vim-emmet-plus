let s:bs = "\<C-H>"
let s:del = "\<Del>"
let s:dels = s:del.s:bs
let s:def_del = repeat(s:del, 2).s:bs
let s:fstr_del = repeat(s:bs, 2).s:del

function! bs#bothside()
    return s:dels
endf
function! bs#del(times=0)
    if a:times == 2
        return s:dels
    elseif a:times > 0
        return repeat(s:del, a:times)
    else
        return s:del
    endif
endf
function! bs#bs(times=0)
    if a:times > 0
        return repeat(s:bs, a:times)
    else
        return s:bs
    endif
endf
function! bs#trails()
    return s:def_del
endf
function! bs#def()
    return s:def_del
endf
function! bs#fstr()
    return s:fstr_del
endf
function! s:del_inside_parens(ptext="")
    if empty(a:ptext)
        let ptext = trim(str#ptext())
    else
        let ptext = a:ptext
    endif

    if str#ptext_has_two(ptext, '(')
            " -> ((|)
        if str#ppchar() == "(" && empty(str#nnchar())
            return s:bs
        elseif empty(str#nnchar())
            " test: render(reqeust(|)
            " -> (request(|)
            return s:bs
        else
            " -> ((|))
            " -> ('(|)')
            "  -> (request(|))
            return s:dels
        endif
    else
        return s:dels
    endif
endf
function! bs#Backspace()
    let ppchar = str#ppchar()
    let pchar = str#pchar()
    let nchar = str#nchar()
    let nnchar = str#nnchar()  
    let ptext = trim(str#ptext())

    if str#inside_pairs() 
        let matched_index = str#ptext_has('[)}\]]')
        if matched_index > 0
            let get_ptext = ptext[matched_index:] 
            return s:del_inside_parens(get_ptext)
        elseif str#nnchar() == ','
            return s:dels."\<Del>"
        else
            return s:del_inside_parens()
        endif
    else
        return s:bs
    endif
endf
