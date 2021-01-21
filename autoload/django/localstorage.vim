function! django#localstorage#getItem(item)
    return string(s:formInstances)
endfun
function! django#localstorage#all()
    return s:formInstances
endfun

let s:formInstances = {
\'form':'NameForm',
\}
