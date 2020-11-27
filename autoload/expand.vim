"====================================================================
" File name     : expand.vim
" Author        : guangxue
" Verson        : v0.1
" Last modified : 23 Oct 2020
"=====================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim


let s:raw_tagtext = ""
let s:raw_htmlattr = ""
let s:expanded_htmlattr = ""
let s:expanded_idclass = ""
let s:expanded_tagtext = ""
let s:expanded_child = ""
let s:expanded_siblings = ""
let s:grouplist = []
let s:EmText = []
let s:EmAttr = ""
let s:force_indent = 0
let s:tablnum = 0
let s:startlnum = 0
let s:stoplnum = 0
let s:jumprange = []
let s:matched_before = ""
let s:matched_after=""
let s:caret = '\${0}'
let s:settings = load#expandsettings()

let s:pat_emmet_abbr ='\(\([(.!#>+]\)*'
\                    .'\(\w\+\(:*\w\+\|\:\d\+\)*\$*'
\                    .'\(\[.\+\]\)*\|'
\                    .'\([.#]\+\w\+[\$@-]*\)*\|'
\                    .'\({.\+}\)*\)*'
\                    .'[)\d]*\(*\d\+\)*\)*$'

let s:pat_multiplication ='\w\+\$*'
\                     .'\%([.#]\+\w\+[\$]*\)*'
\                     .'\%(\[.\+\]\)*'
\                     .'\%({.\+}\)*'
\                     .'\(@-\|@\d\|@-\d\)*'
\                     .'\(*\d\+\)\(>\)\@!'

let s:pat_multi_nest ='\w\+\$*'
\                     .'\%([.#]\+\w\+[\$]*\)*'
\                     .'\%(\[.\+\]\)*'
\                     .'\%({.\+}\)*'
\                     .'\(@-\|@\d\|@-\d\)*'
\                     .'\(*\d>.\+ze)\)'

let s:pat_emmet_base ='\(\w\+\$*'
\                    .'\([.#]\+\w\+[\$]*\)*'
\                    .'\(\[.\+\]\)*'
\                    .'\({.\+}\)*\)*'

let s:pat_inside_multi ='\(>\w\+'
\                     .'\([.#]\+\w\+[\$]*\)*'
\                     .'\(\[.\+\]\)*'
\                     .'\({.\+}\)*\)\+$'

let s:pat_excl_emmet ='\(\([(.!#>+]\)*'
\                    .'\(\w\+\$\+\(\[.\+\]\)\+'
\                    .'\([.#]\+\w\+[\$@-]*\)*'
\                    .'\({.\+}\)*\)*'
\                    .'[)\d]*\(*\d\+\)*\)*$'

let s:pat_emmet_group = '([^()]\{-})\(*\d\)*'
let s:pat_mul_inner_group = '([^()]\{-})\(*\d\+\)'
let s:pat_emmet_sibling = '\(\(\w\+\(\[.\+\]\)*\([.#]\+\w\+\)*\({.\+}\)*\)[+]*\)*'

let s:pat_htmlattr = '\(\[.\+\]\)\+'
let s:pat_idclass = '\([.#]\+\w\+[\$]*\)\+'
let s:pat_tagtext = '{.\+}'
let s:tag_content = '<\w\+>.\+<\/\w\+>'


function! s:tag_args()
    let tag_args = ""
    if !empty(s:expanded_htmlattr) && !empty(s:expanded_idclass)
        let tag_args = ' '.s:expanded_htmlattr.' '.s:expanded_idclass
    elseif !empty(s:expanded_htmlattr) && empty(s:expanded_idclass)
        let tag_args = ' '.s:expanded_htmlattr
    elseif !empty(s:expanded_idclass) && empty(s:expanded_htmlattr)
        let tag_args = ' '.s:expanded_idclass
    else
        let tag_args = ""
    endif
    return trim(tag_args, ' ', 2)
endf

function! s:set_default(tagname)
    if empty(s:expanded_htmlattr)
        let tagname = a:tagname
        if has_key(s:settings.html.default, tagname)
            let s:expanded_htmlattr = s:settings.html.default[tagname]
        endif
    endif
endf

function! s:void_element(matched_tag)
    let matched_tag = a:matched_tag
    let idx = index(s:settings.html.void, matched_tag)
    if idx >= 0
        call s:set_default(matched_tag)
        return matched_tag
    else
        return ""
    endif
endf

"" __expands
function! s:expands(stripd_abbr)
    let tagname = a:stripd_abbr
    let expanded = ""

    let voidtag = s:void_element(tagname)
    let tag_args = s:tag_args()
    if !empty(voidtag)
        "tagname is single tag
        call s:set_default(voidtag)
        let expanded = '<'.voidtag.tag_args.'>'.s:expanded_tagtext."${0}"
        return expanded
    endif

    call s:set_default(tagname)
    let tag_args = s:tag_args()
    if str#isalpha(tagname)
        if !empty(s:expanded_tagtext)
            let ld = '<'.tagname.tag_args.'>'.s:expanded_tagtext."${0}"
        else
            let ld = '<'.tagname.tag_args.'>'."${0}"
        endif
        let rd = '</'.tagname.'>'
        let expanded = ld.rd
        return expanded
    endif
endf

function! s:matchstr_idclass(stripd_emmet)
    let matched_idclass = matchstr(a:stripd_emmet, s:pat_idclass)
    if empty(matched_idclass)
        return a:stripd_emmet
    endif
    
    let get_classes = matchstr(matched_idclass, '\([.][0-9a-zA-Z$]\+\)\+')
    let get_ids = matchstr(matched_idclass, '\(#\{1}[0-9a-zA-Z]\+\)\+')
    let idname = strpart(get_ids, '1')
    let classlist = substitute(get_classes, "[.]", " ","g")
    let ld = ""

    if !empty(idname)
        let id_str = 'id="'.idname.'"'
        let ld = id_str
    endif
    if !empty(classlist)
        let class_str = 'class="'.trim(classlist).'"'
        if empty(idname)
            let ld = class_str
        else
            let ld = id_str.' '.class_str
        endif
    endif
    let s:expanded_idclass = ld 
    let stripd_emmet = substitute(a:stripd_emmet, s:pat_idclass, "", 'g')
    return stripd_emmet
endf



" "__matchstr_attr"
function! s:matchstr_attr(stripd_emmet)
    let matched_attr = matchstr(a:stripd_emmet, s:pat_htmlattr)
    if empty(matched_attr)
        return a:stripd_emmet
    endif

    let matched_attr = trim(matched_attr, '[]')
    let final_htmlattrs = ""
    

    if matched_attr =~ 'EmAttr'
        let matched_attr = trim(s:EmAttr, '[]')
    endif

    " Replace all  \' to \"
    " and ignore everything inside double quotations
    let matched_attr = substitute(matched_attr, "'", '"', 'g')
    let pat_inqs = '\(\w\+="\)\@<=.\{-}\("\s\+\|"$\)\@=' 
    let inqs = str#matchall(matched_attr, pat_inqs)

    let qtcounts = str#matchcount(matched_attr, pat_inqs)
    let maxdepth = 0
    for qt in range(qtcounts)
        if maxdepth > 10
            break
        endif
        let matched_attr = substitute(matched_attr, pat_inqs, '$qs:'.maxdepth.'$', '')
        let maxdepth += 1
    endfor

    " Replace all matched non-quoted val with quoted
    " : attr=val
    let noq_lst = []
    let pat_noq = '=\zs[^"]\{-}\(\s\|$\)\@='
    let noq_lst = str#matchall(matched_attr, pat_noq)
    if len(noq_lst) > 0
        for noq in noq_lst
            let matched_attr = substitute(matched_attr, pat_noq, '"'.noq.'"', '')
        endfor
    endif

    " Replace all `attrname` with attrname=""
    let attrname = []
    let pat_attrname = '\(\s\|^\)\zs[^{}]\w\+\ze\(\s\|$\)'
    let attr_names = str#matchall(matched_attr, pat_attrname)
    if len(attr_names) > 0
        for attr in attr_names
            let matched_attr = substitute(matched_attr, pat_attrname, attr.'="${0}"', '')
        endfor
    endif


    " Deal with fancy attribute name: `attr=`
    let exotic_attr = []
    let pat_exotic = '\s\zs\w\+=\(\s\|$\)\@='
    let matched_exo = matchstr(matched_attr, pat_exotic)
    call substitute(matched_attr, pat_exotic, '\=add(exotic_attr, submatch(0))', 'g')
    if len(exotic_attr) > 0
        for attr in exotic_attr
            let matched_attr = substitute(matched_attr, pat_exotic, attr.'""', '')
        endfor
    endif
    
    " Example:  a[href='{{{ post.get_absolute_url }}}']{{{ post.title }}}
    " -> a[href=$text:3$]
    let midx = 0
    while matched_attr =~ '$text:'
        if midx > 10
            break
        endif
        let emidx = matchstr(matched_attr, '\(\$text:\)\@<=\d\+')
        let matched_attr = substitute(matched_attr, '\$text:\d\+\$', s:EmText[emidx], '')
        let midx += 1
    endwhile

    while matched_attr =~ '\$qs:\d\+\$'
        if maxdepth > 10
            break
        endif
        let idx = matchstr(matched_attr, '\(\$qs:\)\@<=\d\+')
        let matched_attr = substitute(matched_attr, '\(\$qs:\d\+\$\)', inqs[idx], '')
        let maxdepth += 1
    endwhile

    let final_htmlattrs = matched_attr 
    let s:expanded_htmlattr = final_htmlattrs
    let stripd_emmet = substitute(a:stripd_emmet, s:pat_htmlattr, "", 'g')
    return stripd_emmet 
endf

" __parse_texts
function! s:parse_texts()
    let idx = 0
    for emt in s:EmText
        while s:EmText[idx] =~ '\$text:'
            if idx > 10
                break
            endif
            let cid = matchstr(s:EmText[idx], '\(\$text:\)\@<=\d\+')
            let s:EmText[idx] = substitute(s:EmText[idx], '\$text\:\d\+\$', s:EmText[cid], '')
        endwhile
        let idx += 1
    endfor
endf

"_matchstr_text
function! s:matchstr_text(matched_emmet) 

    let matched_emmet = a:matched_emmet
    let matched_text = matchstr(matched_emmet, '\({.\+}\)')

    if empty(matched_text) || matched_text == '{0}' || matched_text =~ '\${\d\+:\w\+\}'
        return matched_emmet
    endif

    let final_text = matched_text[1:-2]
    if final_text =~ '\$text:'
        call s:parse_texts()
        let idx = matchstr(final_text, '\d\+')
        let final_text = substitute(final_text, '\$text\:\d\+\$', s:EmText[idx], '')
        if final_text =~ '\${\w\+}'
            let split_text = split(final_text, '\${')
            let final_text = split_text[0][1:-2]."${".split_text[1]
        else
            let final_text = final_text[1:-2]
        endif
    endif

    let s:expanded_tagtext = final_text
    let return_matched_emmet = substitute(matched_emmet, s:pat_tagtext, "", "g")
    return return_matched_emmet
endf

"__expand_base"
function! s:expand_base(matched_base)
    if a:matched_base =~ '\$grouplist'
        let grp_idx = matchstr(a:matched_base, '\d')
        let grp_cmd = matchstr(a:matched_base, '\${\(NL\|child\)}')
        " last group with tail nest '>', in fact should be '+'
        if grp_cmd == "${child}"
            let grp_cmd = "${NL}"
        endif
        let grp_ret = "$grouplist:".grp_idx.'$'.grp_cmd
        return grp_ret
    endif

    " remove dirty data before initialise script variables
    let s:expanded_htmlattr = ""
    let s:expanded_idclass = ""
    let s:expanded_tagtext = ""

    let stripd_base = ""

    if !empty(a:matched_base)
        let stripd_base = s:matchstr_text(a:matched_base)
    endif

    if !empty(stripd_base)
        let stripd_base = s:matchstr_attr(stripd_base)
    endif

    if !empty(stripd_base)
        let stripd_base = s:matchstr_idclass(stripd_base)
    endif

    if !empty(stripd_base)
        let htmltags = s:expands(stripd_base)
        if empty(htmltags)
            return a:matched_base
        endif
        return htmltags
    endif
endf


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" function: "_parse_valid_group()"
" Purpose : Recursively parse grouplist, so that
"           to get correct tabsize for each element in grouplist
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:parse_valid_group(idx)
    let i = a:idx
    " 
    if empty(s:grouplist[i].tabs)
        if s:grouplist[i].tabs == 0
            call s:parse_abbr(s:grouplist[i].val, s:grouplist[i].tabs, 1)
        else
            call s:parse_valid_group(i+1)
        endif
    else
        call s:parse_abbr(s:grouplist[i].val, s:grouplist[i].tabs, 1)
    endif
endf

" _parse_groups
function! s:parse_groups(last_expand)
    let last_expand = a:last_expand
    let grouplen = len(s:grouplist)

    " "#1.Parse grouplist backwards": to get tabsize value for each element.
    " if current element has no tabsize vale, parse +1 element
    for i in range(grouplen-1, 0, -1)
        call s:parse_valid_group(i)
    endfor

    " "#2.Parsing each group element":
    " Now, each element has `tabs` value, and parse each element.
    for idx in range(grouplen)
        let s:grouplist[idx].val = s:parse_abbr(s:grouplist[idx].val, s:grouplist[idx].tabs, 1)
    endfor

    " - After parsed each value in grouplist
    " ":substitute": 'grouplist:5' pat with parsed_abbr in s:grouplist
    for idx in range(grouplen)
        if s:grouplist[idx].val =~ '\$grouplist:\$'
            let grp_idx = matchstr(s:grouplist[idx].val, '\(\$grouplist:\)\@<=\d\+')
            let s:grouplist[idx].val = substitute(s:grouplist[idx].val, '\$grouplist:\d\+\$', s:grouplist[grp_idx].val, '')
        endif
    endfor

    
    " - return final expand_abbr
    " ":substitute" last_expand with specific index of grouplist
    let idx = 0
    while last_expand =~ '\$grouplist'
        if idx > 10
            break
        endif
        let grp_idx = matchstr(last_expand, '\(\:\)\@<=\d\+')
        let grp_idx = trim(grp_idx, '[]')
        let matched_gname = matchstr(last_expand, '\$grouplist\:\d\+\$')
        if matched_gname =~'\$grouplist'
            let last_expand = substitute(last_expand, '\$grouplist\:\d\+\$', s:grouplist[grp_idx].val, '')
        endif
        let idx += 1
    endwhile
    
    " "return final expaned abbr if `grouplist` exists"
    return last_expand
endf

function! Sanitize_abbr(polished_abbr)
    if a:polished_abbr =~ '^[(.!#>+]'
        return a:polished_abbr[1:]
    elseif a:polished_abbr =~ '^\d'
        return ""
    else
        return a:polished_abbr
    endif
endf

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" function    : " __parse_abbr() "
" Purpose     : parse single abbr -> div>grouplist[1]+p>a
" tabs        : number, tabsize for left side indent.
" parsegroups : if parse groups, leading ltabs is discard.
" last_cmd    : if last_expand has token ${child} -> ltabs+1,
"               otherwise ltabs = a:tabs
" last_expand : if last_expand has token ${child},
"               replace it with curr_expand, and add 1 tabsize
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:parse_abbr(matched_abbr, tabs=0, parsegroups=0)
    let abbr_str = Sanitize_abbr(a:matched_abbr)
    if empty(abbr_str)
        return a:matched_abbr
    endif

    " extract []
    let pat_attr = '\(\(\w\+\)\@<=\[.\+\]\([+>]\)\@=\)\|\(\w\+\)\@<=\[.\+\]'
    let m_attr = str#matchall(abbr_str, pat_attr)
    let attrlst = str#matchcount(abbr_str, pat_attr)
    for ix in range(attrlst)
        let abbr_str = substitute(abbr_str, pat_attr, '$attr:'.ix.'$', '')
    endfor

    " extract {} 
    let idx = 0
    let pat_elm_text = '\({[^{}]\{-}}\)'
    while abbr_str =~ '{'
        if idx > 10
            break
        endif
        let text = matchstr(abbr_str, pat_elm_text)
        call add(s:EmText, text)
        let abbr_str = substitute(abbr_str, pat_elm_text, '$text:'.idx.'$', '')
        let idx += 1
    endwhile

    let abbr_str = substitute(abbr_str, '>', "{${child}}${sep}", 'g')
    let abbr_str = substitute(abbr_str, '+', "{${NL}}${sep}", 'g')


    let max = 0
    while abbr_str =~ '\$attr:'
        if max > 10
            break
		endif
        let idx = matchstr(abbr_str, '\(\$attr:\)\@<=\d\+')
        let abbr_str = substitute(abbr_str, '\$attr:\d\+\$', m_attr[idx], '')
    endwhile


    let abbr_list = split(abbr_str, '\${sep}')
    " - Tab setup:
    " set ltabs globally in function, so that
    " each loop can track current `ltabs` size
    let ltabs = a:tabs

    " replace ${child}/${NL} in last_expand with curr_expand
    let last_expand = ""
    for abbr in abbr_list
        let getattr = matchstr(abbr, '\(\w\+\)\@<=\(\[.\+\]\)')
        " parse attributes []
        if !empty(getattr)
            let abbr = substitute(abbr, '\(\w\+\)\@<=\(\[.\+\]\)', '[EmAttr]', '')
            let s:EmAttr = getattr
        endif
        let EmText = matchstr(abbr, '\zs\$text\:\d\+\$')
        let CMD = matchstr(abbr, '${\w\+}')
        " arrange abbr orders
        if empty(CMD)
            let abbr = substitute(abbr, '\zs\$text\:\d\+\$', '{'.EmText.'}', '')
        else
            let abbr = substitute(abbr, '\zs\$text\:\d\+\$', '', '')
            let abbr = substitute(abbr, '{\${\w\+}}', '{'.EmText.CMD.'}', '')
        endif

        if abbr =~ '\\n'
            let s:force_indent = 1
            let abbr = substitute(abbr, '\\n', '', 'g')
        endif

        let tagname = matchstr(abbr, '\w\+')
        let curr_expand = ""
        let curr_expand = s:expand_base(abbr)
        if curr_expand =~ '\${child}'
            let curr_expand = substitute(curr_expand, '\', '', 'g')
        endif
        if empty(curr_expand)
            return abbr
        endif
        let curr_cmd = matchstr(curr_expand, '\${\(child\|NL\)}')

        " if curr_expand outputs <div>${NL}</div>
        " change it to <div></div>${NL}
        if curr_cmd == "${NL}"
            if curr_expand =~ '\(<\/\w\+>\|<\/\w\+\*\d\+>\)'
                let curr_expand = substitute(curr_expand, '\${NL}', '', 'g')
                let curr_expand = curr_expand."${NL}"
            endif
        endif
        
        " initialise the `last_expand` value
        if empty(last_expand)
            " void leading indent for the first last_expand
            if a:parsegroups > 0
                let last_expand = curr_expand
            else
                let lindent = repeat("\t", ltabs)
                let last_expand = lindent.curr_expand
            endif
        else
            " get last_expand cmd
            let last_cmd = matchstr(last_expand, '\${\(child\|NL\)}')

            " Only increment `ltabs` when ${child}.
            " Otherwise, `ltabs` remain last number.
            if last_cmd == "${child}"
                let ltabs += 1
                let rtabs = ltabs - 1
                let lindent = repeat("\t", ltabs)
                let rindent = repeat("\t", rtabs)

                let is_inline = index(s:settings.html.inline, tagname)
                if is_inline >= 0 && s:force_indent <= 0
                    let next_expand = curr_expand
                else
                    let next_expand = "\n".lindent.curr_expand."\n".rindent
                    let s:force_indent = 0
                endif
                let last_expand = substitute(last_expand, '\${child}', next_expand, 'g')
            endif
            if last_cmd == "${NL}"
                let lindent = repeat("\t", ltabs)
                let last_expand = substitute(last_expand, '\${NL}', "\n".lindent.curr_expand , 'g')
            endif
        endif
        " get: correct grouplist index 
        " set: correct ltabs for grouplist
        " before: for-loop ended
        if abbr =~ '\$grouplist:'
            let grp_idx = matchstr(abbr, '\d') 
            if empty(s:grouplist[grp_idx].tabs)
                let s:grouplist[grp_idx].tabs = ltabs
            endif
        endif
    endfor
    
    let s:force_indent = 0
    return last_expand
endf



" __matched_before_after
function! s:matched_before_after(ptext, matched)
    let ptext_len = len(str#ptext())
    let match_len = len(a:matched)
    let idx = ptext_len - match_len
    
    if idx != 0
        let s:matched_before = getline('.')[0:idx-1]
    else
        let s:matched_before = ""
    endif
    let s:matched_after = getline('.')[col('.')-1:]
endf

function! SubTabs(output)
    "let tabs = a:tabnums
    let sw = shiftwidth()
    let Tab = repeat(' ', sw)
    let output = substitute(a:output, "\t", Tab, 'g')
    return output
endf

function! TabNums()
    let tabnum = indent('.')
    let tabs = tabnum / &sw
    return tabs
endf

" _get_numbered
function! s:get_numbered(multiplied, start, end, stride=1)
    let numbered = ""
    let pat_number = '\(\(\w\+\)\|\(\w\+\s\+\)\)\@<=\(\$\+\)'
    let loops = str#matchcount(a:multiplied, pat_number)
    for num in range(a:start, a:end, a:stride) 
        let multi = a:multiplied
        for i in range(loops)
            let ds = matchstr(multi, pat_number)
            if empty(ds)
                break
            endif
            let multi = substitute(multi, pat_number, printf("%0".len(ds)."d", num), '')
        endfor
        let numbered .=multi 
    endfor
    return numbered
endf

" _numbering
function! s:numbering(multiplied, times, starts)
    let multiplied = substitute(a:multiplied, '\${0}', '|', 'g')
    let numbered = ""
    
    if empty(a:starts)
        let numbered = s:get_numbered(multiplied, 1, a:times)
    endif

    if a:starts =~ '^\d'
        let max = a:starts-1+a:times
        let numbered = s:get_numbered(multiplied, a:starts, max)
    endif

    if a:starts =~ '^-$'
        let start = a:times
        let numbered = s:get_numbered(multiplied, start, 1, -1)
    endif
    
    if a:starts =~ '^-\d\+$'
        let end = matchstr(a:starts, '\d\+')
        let start = a:times+end-1
        let numbered = s:get_numbered(multiplied, start, end, -1)
    endif

    let numbered = substitute(trim(numbered), "\<Bar>", '\${0}', 'g')
    return numbered
endf

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" parse multiplied tags before setlines
" <dl*2>...</dl*2>
"""""""""""""""""""""""""""""""""""""""""""""""""""""
" __multiple_tags
function! s:multiple_tags(expanded_abbr)
    let expanded_abbr = a:expanded_abbr
    let pat_mtags = '<\w\+\$*\(@-\|@\d\|@-\d\)*\*\d\+'
    let multitags = str#matchall(expanded_abbr, pat_mtags)
    if len(multitags)>0
        " parse most inner tags first
        " Example ul>li*3>a*3 -> parse <a*3> first
        for multag in reverse(multitags)
            " replace open multiple tags into: <a\$\*
            let mul_optag = substitute(multag, '\*', '\\*', 'g')
            let mul_optag = substitute(mul_optag, '\$', '\\$', 'g')

            " replace close multiple tags into: <\/a\$ >
            let mul_cltag = substitute(mul_optag, '<', '<\\/', 'g').'>'
            let mul_cltag = substitute(mul_cltag, '\$', '\$', 'g')

            " get everything before open multiple tags: ...<a$*3></a$*3>
            let before_mtag = matchstr(expanded_abbr, '.\+\('.mul_optag.'\)\@=')
            let split_bform = split(before_mtag, "\n")
            
            " get indent before non-whitespace
            let indent = len(split_bform) > 0 ? split_bform[-1] : ''
            let indent = matchstr(indent, '^\s\+\(\S\|$\)\@=')

            " starts and times
            let times = matchstr(multag, '\(\*\)\@<=\d\+')
            let starts = matchstr(multag, '\(@\)\@<=\(\d\+\)\|\(-\d\+\)\|\(-\)')
            
            " get everything between multiple tags
            let pat_between_multags = mul_optag.'.\{-}'.mul_cltag
            let between_matched_multags = matchstr(expanded_abbr, pat_between_multags)

            let tagname = matchstr(multag, '\w\+\$*')
            let def_attr = get(s:settings.html.default, tagname, "")
            let def_attr = !empty(def_attr) ? ' '.def_attr : ""
            
            " remove multi symbol(@-5*3) in tags
            let between_multags = substitute(between_matched_multags, '\(@-\d*\|@\d\|\*\d\+\)', def_attr, '')
            let between_multags = substitute(between_multags, '\(@-\d*\|@\d\|\*\d\+\)', '', 'g')

            let is_inline = index(s:settings.html.inline, tagname)
            if is_inline >= 0 && before_mtag =~ '\(<\w\+\|<\w\+\*\d\+\)'
                let inline_indent = "\n\t".indent
                let unindent = "\n".indent
                let multiplied = between_multags.inline_indent
                let multiplied = s:numbering(multiplied, times, starts)
                let multiplied = inline_indent.multiplied.unindent
            else
                let multiplied = between_multags."\n".indent
                let multiplied = s:numbering(multiplied, times, starts)
            endif
            let expanded_abbr = substitute(expanded_abbr, pat_between_multags, multiplied, 'g')
        endfor
    endif
    return expanded_abbr
endf

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" function: "_extract_groups"
" Return  : "return": div+$grouplist:0$+$grouplist:2$
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:extract_groups(multiplied_abbr)
    let refined_abbr = a:multiplied_abbr
    let s:grouplist = []
    let gidx = 0

    while refined_abbr =~ '('
        let matched_group = matchstr(refined_abbr, s:pat_emmet_group)
        if !empty(matched_group)
            if gidx > 20
                break
            endif
            " initialise s:grouplist[]
            let last_char = matched_group[len(matched_group)-1]
            if last_char == ')' 
                "#2: add `div>p` to grouplist[] if matched_group is (div+p)
                call add(s:grouplist, {'val': trim(matched_group, '()'), 'tabs':''})
            else
                "#2": add '(li>a)*2' to grouplist without trim ()
                call add(s:grouplist, {'val': matched_group, 'tabs':''})
            endif
            let refined_abbr = substitute(refined_abbr, s:pat_emmet_group, '$grouplist:'.gidx.'$', '')
            let gidx += 1
        else
            break
        endif
    endwhile
    "#3 return div+grouplist[0]+grouplist[2]
    return refined_abbr
endf

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" function : " _multiple_abbr()"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:multiple_abbr(matched_abbr)
    let multiplied_abbr = a:matched_abbr

    " "parse inner/outer group with mulitiplications"
    """""""""""""""""""""""""""""""""""""""""""""""""""""
    " For example: (div*2>dl>(dt+dd)*3)*2+footer>p
    " parse_inner_group: (dt+dd)*3
    """""""""""""""""""""""""""""""""""""""""""""""""""""
    let mul_inner_groups = str#matchall(multiplied_abbr, s:pat_mul_inner_group)
    if len(mul_inner_groups) > 0
        for inner_group in mul_inner_groups
            let grp_base = matchstr(inner_group, '(.\+)')
            let times = matchstr(inner_group, '\d\+')
            let new_inner = ''
            for i in range(times)
                let new_inner .= grp_base.'+'
            endfor
            let new_inner = new_inner[:-2]
            let multiplied_abbr = substitute(multiplied_abbr, s:pat_mul_inner_group, new_inner, '')
        endfor
    endif

    """""""""""""""""""""""""""""""""""""""""""""""""""""""
    " parse outer group with multiplication
    " multi_group : ( div*2>dl>(dt+dd)+(dt+dd)+(dt+dd) )*2
    """""""""""""""""""""""""""""""""""""""""""""""""""""""
    let pat_mul_outer_group = '\%((.\+)\)\(*\d\+\)'
    let mul_outer_groups = str#matchall(multiplied_abbr, pat_mul_outer_group)

    let multi_outer = ""
    if len(mul_outer_groups)>0
        for mul_outer_group in mul_outer_groups
            let grp_base = matchstr(mul_outer_group, '(.\+)')
            let times = split(mul_outer_group, '*')[-1]
            let new_outer = repeat(grp_base.'+', times)
            let new_outer = new_outer[:-2]
            let multi_outer = substitute(multiplied_abbr, pat_mul_outer_group, new_outer, '')
        endfor
    endif
    if !empty(multi_outer)
        return multi_outer
    endif
    return multiplied_abbr
    
endfunction

function! SetCursor()
    let lnum = line('.')
    call cursor(lnum, 1)
    let [lnum, col] = searchpos('\${0}')
    silent! %s/\${0}//g
    call cursor(lnum, col)
    return ''
endf

"__setlines
function! Setlines(lines)
    let lines = split(a:lines, '\n')
    if len(lines) == 1
        let line = s:matched_before.trim(lines[0]).s:matched_after
        let s:stoplnum = s:tablnum
        call setline('.', line)
    else
        let line0 = s:matched_before.trim(lines[0])
        let eol = lines[-1].s:matched_after
        let nextlines = lines[1:-2]
        let nextlines = add(nextlines, eol)
        let s:stoplnum = s:tablnum + len(nextlines)
        call setline('.', line0)
        call append('.', nextlines)
    endif
    let s:jumprange = range(s:tablnum, s:stoplnum)
endf

" __jumping
function! s:jumping()
    let rest = str#after()
    let b_cur = trim(str#before())
    let ptext = str#ptext()
    let c_lnum = line('.')
    let stopline = c_lnum + s:stoplnum
    let pat_caret = '\(\${\d:\=\)\|\(<\w\+\s*\(\w\+=".*"\s*\)*\)\@<=\zs><\(\/\w\+>\)\@=\|\(""\)'

    let css_stoplnum = buf#stopline()

    if index(s:jumprange, s:tablnum) < 0 && s:stoplnum > 0
        let s:stoplnum = 0
    endif
    if  str#nchar() == '"'
        if s:stoplnum != 0
            let [lnum, col] = searchpos(pat_caret, 'zW', s:stoplnum)
            let char = getline(lnum)[col]
            if col!= 0
                if char == '{' 
                    call cursor(lnum, col)
                    exe "\<ESC>v4l"
                    return ''
                endif
                call cursor(lnum, col+1)
                call feedkeys("\<BS>")
                return ''
            endif
        endif
    elseif b_cur =~ '^{%'
        let [lnum, col] = searchpos('\${\d}', 'zW', c_lnum)
        if col!= 0
            call cursor(lnum, col+1)
            call feedkeys("\<BS>\<ESC>vf}")
            return ""
        endif
    elseif rest =~ '^<\/\w\+>'
        if s:stoplnum != 0
            let [lnum, col] = searchpos(pat_caret, 'zW', s:stoplnum)
            if col!= 0
                call cursor(lnum, col+1)
                call feedkeys("\<BS>")
                return ''
            endif
        endif
    elseif css_stoplnum > 0
        let [lnum, col] = searchpos('\(\${\d:\=\)', 'zW', css_stoplnum)
        if lnum == 0
            call buf#reset_stopline()
		endif
        let char = getline(lnum)[col-1]
        if char == '$'
            call cursor(lnum, col+1)
            call feedkeys("\<BS>\<ESC>vf}")
            return ''
        endif
    else
        return 'nope!'
    endif
endf

function expand#selection(selected)
    return Expand_abbr(a:selected)
endf
" __Expand_abbr
function! Expand_abbr(matched_abbr)

    let jumping = s:jumping()

    if !empty(a:matched_abbr) && jumping == 'nope!'
        " "1 - get multiplied abbr"
        let multiplied_abbr = s:multiple_abbr(a:matched_abbr)

        " "2 -extract groups of abbr"
        let grouped_abbr = s:extract_groups(multiplied_abbr)

        " "3 -Get current tabsize when <Tab> pressed"
        let tabs = TabNums()
        " Parse grouped abbr for the first time to get tabsize for if grouplist exists.
        " otherwise, parse abbr as normal
        " "4 -parsing grouped abbr"
        let last_expand = s:parse_abbr(grouped_abbr, tabs)

        " "5 -Parse groups"
        let expanded_abbr = s:parse_groups(last_expand)

        " "6 - multiple tags"
        let multiplied_tags = s:multiple_tags(expanded_abbr)

        " "7 - Sub Tabs"
        let expanded = SubTabs(multiplied_tags)

        " "8 -Reset EmText"
        let s:EmText = []

        return expanded
    endif
    return "\<Tab>"
endf

" __matched_emmet
function! s:matched_emmet()
    let ptext = str#ptext()
    if empty(ptext)
        return ["", ""]
    endif

    let rawtext = ptext
    let pat_tag = '\(<.\{-}>\)\|\(<\/.\{-}>\)'
    let rtidx = 0
    while rawtext =~ pat_tag
        if rtidx > 10
            break
        endif
        let match_tag = matchstr(ptext, pat_tag)
        let rawtext = substitute(rawtext, pat_tag, '${tag}', 'g') 
    endwhile
    
    let pat_btwn_tags = '\(\${tag}.\+\${tag}\)' 
    let btwn_tags = matchstr(rawtext, pat_btwn_tags)
    let rawtext = substitute(rawtext, pat_btwn_tags, '', 'g')

   
    if !empty(rawtext)
        let refined = split(rawtext, '\(\${tag}\)')
        let refined = len(refined) > 1 ? refined[-1] : refined[0]
    endif
    
    if empty(rawtext) || rawtext == "${tag}${tag}"
        let ptext = ""
        let refined = ""
    endif

    let matched_abbr = matchstr(refined, s:pat_emmet_abbr)
    call s:matched_before_after(ptext, matched_abbr)

    return [refined, matched_abbr]
endf


function! SnippetVariables(snippet)
    let snippet = a:snippet
    while snippet =~ '${\w\+}'
        let key = matchstr(snippet, '\${\zs\w\+\ze}')
        if !has_key(s:settings.variables, key)
            break
        endif
        let snippet = substitute(snippet,'\${\w\+}', '"'.s:settings.variables[key].'"', '')
    endwhile
    return snippet
endf

function! InStyles()
    let foundornot = searchpair('<style>', '', '</style>', 'Wbn') > 0
    if foundornot > 0
        return 1
    else
        return 0
    endif
endf

" __main__ : expand#abbr()"
function! expand#abbr()
    let matched_emmet = s:matched_emmet()
    let matched_abbr = matched_emmet[1]
    let snip = matched_abbr
    let htmldjango_snippets = load#snippets('htmldjango')
    let html_snippets = load#snippets('html')
    let css_snippets = load#snippets('css')

    let s:tablnum = line('.')
    if &ft == 'css' || InStyles()
        return snippet#css()
    endif

    if !has_key(html_snippets, snip)
        if InStyles()
            return "\<Tab>"
		endif
        let expanded = Expand_abbr(matched_abbr)
        if expanded == "\<Tab>"
            return "\<Tab>"
        endif
        call Setlines(expanded)
        return SetCursor()
    endif

    let snippet = html_snippets[snip]
    let snippet =  SnippetVariables(snippet)
    if snippet  =~ "\n"
        let Tab = repeat(' ', &sw)
        let snippet = SubTabs(snippet)
        call Setlines(snippet)
        return SetCursor()
    else
        let expanded =  Expand_abbr(snippet)
        call Setlines(expanded)
        return SetCursor()
    endif
    return "\<Tab>"
endf

let &cpoptions = s:save_cpo
unlet s:save_cpo
