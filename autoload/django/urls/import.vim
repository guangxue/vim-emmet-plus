
function! django#urls#import#all()
    return ['LocalePrefixPattern', 'NoReverseMatch', 'URLPattern',
    \   'URLResolver', 'Resolver404', 'ResolverMatch', 'clear_script_prefix',
    \   'clear_url_caches', 'get_callable', 'get_mod_func', 'get_ns_resolver',
    \   'get_resolver', 'get_script_prefix', 'get_urlconf', 'include',
    \   'is_valid_path', 'path', 're_path', 'register_converter', 'resolve',
    \   'reverse', 'reverse_lazy', 'set_script_prefix', 'set_urlconf', 'translate_url',
    \]
endfun

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

