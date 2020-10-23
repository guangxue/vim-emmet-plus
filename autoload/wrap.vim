function! s:wrap_blocks()
    let lcol = col("'<")-1
    let rcol = col("'>")-1
    let selected = getline('.')[lcol:rcol]
    let before = getline('.')[0:lcol-1]
    let after = getline('.')[rcol+1:]
    let input_abbr = input("Wrap: ")
    let to_expand = input_abbr.'{'.selected.'}'
    let expanded = expand#selection(to_expand)
    call buf#setlines(expanded, before, after)
    call buf#cursor('${0}')
endf

function! s:wrap_lines()
    let upline = line("'<")
    let downl = line("'>")
    let lines = getline(upline, downl)
    
    if len(lines) > 1
    endif
    if len(lines) == 1
        let text = ""
        let line = trim(lines[0])
        let uabbr = input("Tag:")
        let text = uabbr
        let finalabbr = uabbr.'{'.line.'}'
        let expanded = s:parse_abbr(finalabbr)
        call Setlines(expanded, 'v')
        return SetCursor()
    endif
endf
function! wrap#abbr()
    if visualmode() == 'v'
        call s:wrap_blocks()
    endif

    if visualmode() == 'V'
        call s:wrap_lines()
    endif
endf

function! wrap#brackets(pair)
    if visualmode() == 'v'
        let pair = a:pair
        let lcol = col("'<")-1
        let rcol = col("'>")-2
        let selected = getline('.')[lcol:rcol]
        let selected_before = ""
        if lcol > 0
            let selected_before = getline('.')[0:lcol-1]
        endif
        let selected_after = getline('.')[rcol+1:]
        let line = selected_before.pair[0].selected.pair[1].selected_after
        call setline('.', line)
    endif

    if visualmode() == 'V'
        let upline = line("'<")
        let downl = line("'>")
        let lines = getline(upline, downl)
    endif
endf
