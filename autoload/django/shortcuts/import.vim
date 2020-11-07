
function! django#shortcuts#import#all()
    return [ 'render', 'redirect', 'get_object_or_404', 'get_list_or_404', 'resolve_url' ]
endfun

function! django#shortcuts#import#render()
    return {
    \   'params': [
    \       #{word:'request', menu: '<request>', info: 'The request object used to generate this response'},
    \       #{word:"''", menu:'<template_name>', info:"The full name of a template. 'myapp/index.html' "},
    \       #{word:"context", menu:'<dict>'},
    \       #{word:"context_type", menu:'<MIME>',
    \           info:"The MIME type to use for the resulting document. Default to 'text/html'"},
    \       #{word:"status", menu:'<int>', info:'The status code for response. Default to 200'},
    \       #{word:"using", menu:'<str>',
    \           info:'The Name of a template engine to use for loading the template'},
    \   ],
    \}
endfun

function! django#shortcuts#import#redirect()
    return {
    \   'params': [
    \       #{word:'request', menu: '<request>', info: 'The request object used to generate this response'},
    \       #{word:"''", menu:'<template_name>', info:"The full name of a template. 'myapp/index.html' "},
    \       #{word:"context", menu:'<dict>'},
    \       #{word:"context_type", menu:'<MIME>',
    \           info:"The MIME type to use for the resulting document. Default to 'text/html'"},
    \       #{word:"status", menu:'<int>', info:'The status code for response. Default to 200'},
    \       #{word:"using", menu:'<str>',
    \           info:'The Name of a template engine to use for loading the template'},
    \   ],
    \}
endfun
