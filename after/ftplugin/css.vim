set completefunc=complete#popup#func

call map#ifunc({'<Tab>':'expand#abbr',
            \   'feature': {'k':'complete#popup#upkey()', 'j':'complete#popup#downkey()'},
\})
call map#exe()

