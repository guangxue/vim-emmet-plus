function! getlist#fromfile(filename, sep, index)
    let new_list = []
    for line in readfile(a:filename)
        if !empty(line)
            let arr = split(line, a:sep)[a:index]
            call add(new_list, arr)
	    endif
	endfor
    return new_list->uniq()
endfun

function! getlist#fromlines(start, end)
    let new_list = []
    for l in range(a:start, a:end)
        let line = getline(l)->trim()
        call add(new_list, line)
	endfor
    return new_list
endfun

function! getlist#exclude(index_list, exclude_list)
    let new_list = []
    for el in a:exclude_list
        if index(a:index_list, el) < 0
            call add(new_list, el)
        endif
	endfor
    return new_list
endfun

function! getlist#odd(list)
    let idx = 0
    let new_list = []
    for lst in a:list
        if idx % 2 == 0
            call add(new_list, a:list[idx])
        endif
        let idx += 1
	endfor
    return new_list
endfun

function! getlist#even(list)
    let idx = 0
    let new_list = []
    for lst in a:list
        if idx % 2 == 1
            call add(new_list, a:list[idx])
        endif
        let idx += 1
	endfor
    return new_list
endfun
