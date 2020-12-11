function! complete#items#startswith(items, word)
    let matched = []
    for item in a:items
        if item.word =~ '^'.a:word && !empty(a:word)
            call add(matched, item)
        endif
    endfor
    return matched
endfun

function! complete#items#equals(items, word)
    let matched = []
    for item in a:items
        if item.word == a:word
            call add(matched, item)
        endif
    endfor
    return matched
endfun

function! complete#items#user_data(items, word)
    let param_list = []
    for item in a:items
        if item.word == a:word
            let param_list = item.user_data
        endif
    endfor
    return param_list
endfun

function! complete#items#done()
    if str#last2chars() == "''" || str#last2chars() == '""'
        call feedkeys("\<ESC>i")
        return ''
    endif
endfun

function! complete#items#htmltags()
    let startcol = str#bsearch_tagcol(len(str#beforecursor()))
    let voidtags = load#html_inline()
    let taglist = load#htmltaglist()
    let curpos = col('.')-2
    let nearest_tag = getline('.')[startcol:curpos]
    let tagname = str#get_tagname(nearest_tag)
    if empty(tagname)
        return '>'
	endif
    let close_tag ='</'.tagname.'>'
    if str#aftercursor() =~ '^'.close_tag
        let scol = str#bsearch_tagcol(startcol-1)
        let outertag = getline('.')[scol:startcol-1]
        let outertagname = str#get_tagname(outertag)
        if outertagname == tagname
            if index(taglist, tagname) >= 0
                return '>'.close_tag.move#left(len(close_tag))
            else
                return '>'
			endif
        else
            return '>'
        endif
    else
        if index(taglist, tagname) >= 0
            return '>'.close_tag.move#left(len(close_tag))
        else
            return '>'
        endif
    endif
endfun
