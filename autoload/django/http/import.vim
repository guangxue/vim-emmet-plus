function! django#http#import#all()
    return [
        \'SimpleCookie', 'parse_cookie', 'HttpRequest', 'QueryDict',
        \'RawPostDataException', 'UnreadablePostError',
        \'HttpResponse', 'StreamingHttpResponse', 'HttpResponseRedirect',
        \'HttpResponsePermanentRedirect', 'HttpResponseNotModified',
        \'HttpResponseBadRequest', 'HttpResponseForbidden', 'HttpResponseNotFound',
        \'HttpResponseNotAllowed', 'HttpResponseGone', 'HttpResponseServerError',
        \'Http404', 'BadHeaderError', 'JsonResponse', 'FileResponse',
    \]
endfun

function! django#http#import#HttpRequest()
    let request = {
    \   'params': [
    \       #{word:'scheme', menu:'',
    \           info:"{httpRequest.scheme}\n"
    \               ."A string represeting the scheme of the request(http or http usually)."},
    \       #{word:'body', menu:'',
    \           info:"{HttpRequest.body}\n"
    \               ."The raw HTTP request body as a bytestring. This is useful for processing data "
    \               ."in different ways than conventional HTML forms: binary images, XML paylaod etc.\n"
    \               ."For processing conventional form data use `HttpRequest.Post`\n\n"
    \               ."You can also read from an HttpRequest using a file-like\ninterface with "
    \               ."`HttpRequest.read()` or `HttpRequest.readline().` Accessing the body attribute"
    \               ." after reading the request with either of these I/O stream methods will produce a "
    \               ."`RawPostDataException`."},
    \       #{word:'path', menu:'',
    \           info:"A string representing the full path to the request page, "
    \               ."not including the scheme or domain\n\n"
    \               ."For example, if the 'WSGIScriptAlias' for your application is set to "},
    \       #{word:'path_info', menu:'',
    \           info:"Under some Web server configurations, the portion of the URL after the host name"
    \               ." is split up into a script prefix portion and a path info portion."},
    \       #{word:'method', menu:'',
    \           info:"A string representing the HTTP method used in the request."},
    \       #{word:'encoding', menu:'',
    \           info:"A string representing the current encoding used to decode form submision data"},
    \   ]
    \}
    return request
endfun

function! django#http#import#HttpResponse()
    let response = {
    \   'params': [
    \       #{word:'scheme', menu:'',
    \           info:'A string represeting the scheme of the request(http or https usually)'},
    \       #{word:'body', menu:'',
    \           info:'The raw HTTP request body as a bytestring. This is useful for processing data in '
    \               .'different ways than conventinal HMTL forms:binary images, XML playload etc.'},
    \       #{word:'path', menu:'',
    \           info:'A string represeting the full path to the requested page, '
    \               .'not including the scheme or domain'},
    \   ],
    \}
    return response
endfun
