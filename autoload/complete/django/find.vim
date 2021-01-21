function! complete#django#find#manager_names(trigger, fpath)
    let manager_cls = []
    let found_managers = {}
    for line in readfile(a:fpath)
        if line =~ '^class.\+\w\+(models\.Manager):'
            let cls = matchstr(line, '\w\+\((\)\@=')
            call add(manager_cls, cls)
        endif
	endfor
    for line in readfile(a:fpath)
        if line =~ '(models\.Model)'
            let model_name = matchstr(line, '\w\+\((models.Model):\)\@=')
            let found_managers[model_name] = []
        else
            for man in manager_cls
                if line =~ man.'(.*)$'
                    let Fmanager = matchstr(line, '\w\+\(\s\+=\)\@=')
                    if !empty(Fmanager)
                        call add(found_managers[model_name], Fmanager)
                    endif
                endif
            endfor
        endif
    endfor
    return found_managers
endfun
