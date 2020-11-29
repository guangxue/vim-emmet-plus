set completefunc=complete#popup#func

call map#pairs([], 'html')
call map#ifunc({'<Tab>':'expand#abbr', '<C-l>': 'complete#popup#listing',
            \   'feature': {'k':'complete#popup#upkey()', 'j':'complete#popup#downkey()'}
\})
call map#exe()

au BufNewFile,BufRead,BufEnter * call buf#ftdetect()
