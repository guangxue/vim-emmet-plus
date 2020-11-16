function! complete#django#get#foreach_startswith(haystack, needle)
    let matched = []
    for hay in a:haystack
        if hay.word =~ '^'.a:needle && !empty(a:needle)
            call add(matched, hay)
        endif
    endfor
    return matched
endfun

function! complete#django#get#foreach_equals(haystack, needle)
    let matched = []
    for hay in a:haystack
        if hay.word == a:needle
            call add(matched, hay)
        endif
    endfor
    return matched
endfun

function! complete#django#get#array_for(haystack, needle)
    let param_list = []
    for hay in a:haystack
        if hay.word == a:needle
            let param_list = hay.user_data
        endif
    endfor
    return param_list
endfun
