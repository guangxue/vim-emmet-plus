function complete#django#main#func()
    let expr = str#expr()
    let trigger_byauto = {}
    let trigger_bypath = {}

    let django = findfile("manage.py",".;")
    if empty(django)
        return
    elseif django =~ 'manage.py'
        return complete#django#project#menus()
	endif
endfun

