
function! django#contrib#import#admin()
    return {
    \   'subattr': [
    \       #{word:'actions_on_top', menu:""},
    \       #{word:'actions_on_botton', menu:""},
    \       #{word:'actions_selection_counter', menu:""},
    \       #{word:'empty_value_display', menu:"'-empty-'"},
    \       #{word:'exclude', menu:"('birth_date')"},
    \       #{word:'fields', menu:"('url', 'title', 'content')"},
    \       #{word:'fieldset', menu:"((name, field_options), (name, field_options))"},
    \       #{word:'list_display', menu:"('first_name', 'last_name')"},
    \       #{word:'list_display_link', menu:"= ()"},
    \       #{word:'list_filter', menu:"()"},
    \       #{word:'list_select_related', menu:"False"},
    \       #{word:'list_per_page', menu:"100"},
    \       #{word:'list_max_show_all', menu:"200"},
    \       #{word:'list_editable', menu:"()"},
    \       #{word:'search_fields', menu:"()"},
    \       #{word:'date_hierarchy', menu:"'author__pub_date'"},
    \       #{word:'save_as', menu:"False"},
    \       #{word:'save_as_continue', menu:"True"},
    \       #{word:'save_on_top', menu:"False"},
    \       #{word:'preserve_fileters', menu:"True"},
    \       #{word:'inlines', menu:"[]"},
    \   ],
    \   'options':[],
    \}
endfun
