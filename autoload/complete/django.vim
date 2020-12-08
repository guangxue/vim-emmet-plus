function! complete#django#logfpath()
    let logfname = 'django.log'
    let logfpath = globpath(&rtp,'autoload/django/'.logfname) 
    return logfpath
endfun

function! complete#django#from_django(cline)
    if a:cline =~ 'from django.\+import\s\w\+'
        return 1
    else
        return 0
    endif
endfun

" from .models import Blog
function! complete#django#from_models(cline)
    if a:cline =~ 'from\s\(django\)\@!\(\w\+\)*\.models\simport'
        return 1
    else
        return 0
    endif
endfun

" from .views import Home
function! complete#django#from_views(cline)
    if a:cline =~ 'from\s\(django\)\@!\(\w\+\)*\.views\simport'
        return 1
    else
        return 0
    endif
endfun
