let s:snippets = {
\   'php': "<?php ${0} ?>",
\   'get': "$_GET['${0}']",
\   'post': "$_POST['${0}']",
\   'phpinfo': "phpinfo();${0}",
\}
function! PhpSnippet()
    let ptext = str#ptext()
    let trimptext = trim(ptext)
    let snip = len(split(trimptext)) > 0 ? split(trimptext)[-1] : ""
    echom "snip ->".snip
    if !has_key(s:snippets, snip) || empty(snip)
        if snip =~ '^\w'
            return bs#bs(len(snip))."$".snip." = ".'"";'.move#left(2)
        endif
        return "\<Tab>"
    endif
    let ptext_len = strlen(ptext)
    let snip_len = strlen(snip)
    let idx = ptext_len - snip_len

    if idx != 0
        let matched_before = getline('.')[0:idx-1]
    else
        let matched_before = ""
    endif
    let matched_after = getline('.')[col('.')-1:]
    let snippet = s:snippets[snip]
    call buf#setlines(snippet)
    return buf#cursor()
endf

function! PhpAppend(opener, closer)
    if a:opener == '"' && str#pchar() == ' '
        return a:opener.a:closer.move#left(2)
    endif
    return append#brackets(a:opener, a:opener)
endf

function! PhpDel()
    if str#nnchar() == ';' && str#pchar() == '"'
        return bs#trails()
    endif
    return bs#Backspace()
endf

function! PhpEnter()
    let line = getline('.')
    let c = len(line)-1
    let lastchar = line[c]
    let firstchar = trim(line)[0]
    echom "firstchar ->".firstchar
    if lastchar != ';' && firstchar == '$'
        call setline(line('.'), line.';')
        return "\<ESC>o"
    endif
    return "\<CR>"
endf

call map#pairs(['"";'], 'php')
call map#ifunc({'<Tab>':'PhpSnippet', 'append': 'PhpAppend', '<BS>':'PhpDel', '<CR>':'PhpEnter'})
call map#exe()
