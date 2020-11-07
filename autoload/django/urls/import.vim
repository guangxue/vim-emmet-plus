
function! django#urls#import#re_path()
    return  {
    \   'params': [
    \       #{word:"''", menu:'module', info:''},
    \       #{word:"namespace", menu:'None', info:''},
    \   ],
    \}
endfun

function! django#urls#import#path()
    return  {
    \   'params': [
    \       #{word:"''", menu:"<class 'string'>", info:'Path converter - a pattern string'},
    \       #{word:"views.", menu:'view to use', info:''},
    \       #{word:"name=", menu:'name', info:'optional;used to create link'},
    \   ],
    \}
endfun


function! django#urls#import#include()
    return  {
    \   'params': [
    \       #{word:"''", menu:'module', info:''},
    \       #{word:"namespace", menu:'None', info:''},
    \   ],
    \}
endfun

