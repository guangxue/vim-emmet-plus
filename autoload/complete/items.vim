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
