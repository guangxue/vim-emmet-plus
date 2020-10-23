call map#ifunc({'<Tab>':'expand#abbr','<C-l>':'complete#listing',
            \   'feature': {'k':'complete#up()', 'j':'complete#down()'},
\})
call map#exe()

