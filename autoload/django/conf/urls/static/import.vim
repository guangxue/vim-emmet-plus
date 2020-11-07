function! django#conf#urls#static#import#static()
    return {'params': [#{word:'settings.MEDIA_URL',}, #{word: 'document_root=settings.MEDIA_ROOT'}]}
endfun
