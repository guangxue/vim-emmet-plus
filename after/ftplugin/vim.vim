if g:expand_vimscript
    call map#ifunc({'<Tab>':'snippet#vim'})
    call map#exe()
endif
