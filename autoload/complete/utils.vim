function! complete#utils#Menu(list, col=0)
    call complete(col('.')+a:col, a:list)
    return ''
endfun
