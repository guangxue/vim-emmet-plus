set completefunc=complete#func

call map#pairs([], 'html')
call map#ifunc({'<Tab>':'expand#abbr', '<C-l>': 'complete#listing',
            \   'feature': {'k':'complete#up()', 'j':'complete#down()'}
\})
call map#exe()

au BufNewFile,BufRead,BufEnter * call buf#ftdetect()
