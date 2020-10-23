let s:ft = ''

function! s:get(vname)
    if empty(s:ft)
        let ft = 'default'
    endif
    let ft = s:ft

    if a:vname == 'ft'
        return ft
    endif

    if a:vname == 'udp'
        return 'g:emmet_plus_'.ft.'_pairs' 
    endif

    if a:vname == 'ftp'
        return 'g:'.ft.'_pairs'
    endif

    if a:vname == 'ftm'
        return "s:".ft."_maps"
    endif
endf

function! s:add(kmap)
    let ftmaps = s:get('ftm')
    if index({ftmaps}, a:kmap) < 0
        call add({ftmaps}, a:kmap)
    endif
endf

function! s:udpairs()
    let ftpairs = s:get('ftp')
    let udpairs = s:get('udp')
    if !exists(ftpairs)
        let {ftpairs} = []
    endif
    if exists(udpairs)
        call extend({ftpairs}, {udpairs}, 'keep')
    endif
endf

function! map#pairs(pairs=[], ft='default')
    let s:ft = a:ft 
    let udpairs = s:get('udp')
    let ftpairs = s:get('ftp') 
    let {ftpairs} = a:pairs
    call s:udpairs()
endf

function! map#ifunc(ifunc={})
    let ft = s:ft
    let ftpairs = s:get('ftp')
    let ifunc = a:ifunc
    let lhs = "inoremap <silent> <buffer> "
    if !exists(ftpairs)
        let {ftpairs} = []
    endif

    let ftmaps = s:get('ftm') 
    if !exists(ftmaps)
        let {ftmaps} = []
    endif

    if !empty({ftpairs})
        for pair in {ftpairs}
            let appfn = get(ifunc, 'append', 'append#brackets')
            let endapp = str#wrap_qs(str#qs(pair[0], pair[1:])).'<CR>'

            let clsfn = get(ifunc, 'close', 'close#brackets')
            let endcls = str#wrap_qs(str#qs(pair[1])).'<CR>'
            
            let mapapp = lhs.pair[0].' <C-R>='.appfn.endapp
            let mapcls = lhs.pair[1].' <C-R>='.clsfn.endcls
            
            call s:add(mapapp)
            if pair[0] != pair[1]
                call s:add(mapcls)
            endif
        endfor
    endif


    for skey in keys(ifunc)
        if skey =~ '<.\+>'
            let skeymap = lhs.skey.' <C-R>='.ifunc[skey]."()<CR>"
            call s:add(skeymap)
        endif
    endfor

    if has_key(ifunc, 'feature')
        for [trigger, tfunc] in items(ifunc.feature)
            let map = lhs.trigger.' <C-R>='.tfunc."<CR>"
            call s:add(map)
        endfor
    endif
endf

function! map#vfunc(vfunc={})
    let ft = s:ft
    let ftpairs = s:get('ftp')
    let vfunc = a:vfunc
    let lhs = "vnoremap <silent> <buffer> "
    if !exists(ftpairs)
        let {ftpairs} = []
    endif

    let ftmaps = s:get('ftm') 
    if !exists(ftmaps)
        let {ftmaps} = []
    endif
    if !empty(vfunc)
        for [key, vfn] in items(vfunc)
            let map = lhs.key.' :<C-U> call '.vfn."()<CR>"
            call s:add(map)
        endfor
    endif

endf

function! map#nfunc(nfunc={})
    let ft = s:ft
    let ftpairs = s:get('ftp')
    let nfunc = a:nfunc
    let lhs = "nnoremap <silent> <buffer> "
    if !exists(ftpairs)
        let {ftpairs} = []
    endif

    let ftmaps = s:get('ftm') 
    if !exists(ftmaps)
        let {ftmaps} = []
    endif
    if !empty(nfunc)
        for [key, nfn] in items(nfunc)
            let map = lhs.key.' :<C-U> call '.nfn."()<CR>"
            call s:add(map)
        endfor
    endif
endf

function! map#exe()
    let ftmaps = s:get('ftm')

    if exists('s:default_maps')
        for map in s:default_maps
            exe map 
        endfor
    endif

    for map in {ftmaps}
        exe map
    endfor
endf

