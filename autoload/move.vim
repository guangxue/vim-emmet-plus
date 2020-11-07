let s:move = {'toleft':"\<Left>", "toright":"\<Right>"} 

function! move#left(times)
    return repeat(s:move.toleft, a:times)
endfunction

function! move#right(times)
    return repeat(s:move.toright, a:times)
endfunction

function! move#inside()
    let pairs = str#pchar().str#nchar()

    let inside_pairs = str#ppchar().str#nchar()
    if pairs == "''"
        let cl = line('.')
        let linecon = getline(cl-1)
        let lcont = str#sub(linecon, "'", '"', 'g')
        let pat = matchstr(lcont, '".\+"\(,\)\@=')
        if !empty(pat)
            return "',"."\<Del>".move#left(2)
        endif
    elseif pairs == '""'
        let cl = line('.')
        let linecon = getline(cl-1)
        let lcont = str#sub(linecon, '"', "'", 'g')
        let pat = matchstr(lcont, "'.\+'\(,\)\@=")
        if !empty(pat)
            return '",'."\<Del>".move#left(2)
        endif
    elseif str#pchar() == ',' && inside_pairs == "''"
        return bs#bothside()."',".move#left(2)
    elseif str#pchar() == ',' && inside_pairs == '""'
        return bs#bothside().'",'.move#left(2)
    elseif pairs == '()'
        return '),'."\<Del>".move#left(2)
    elseif pairs == '{}'
        return '},'."\<Del>".move#left(2)
    endif
    return ','
endf
