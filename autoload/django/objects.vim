function! django#objects#QuerySet()
    return {
    \   'attrs': [
    \       #{word:'DoesNotExist'},
    \   ],
    \   'chainable': [
    \       #{word:'filter'},
    \       #{word:'exclude'},
    \       #{word:'annotate'},
    \       #{word:'order_by'},
    \       #{word:'reverse'},
    \       #{word:'distinct'},
    \       #{word:'distinct'},
    \       #{word:'values'},
    \       #{word:'values_list'},
    \       #{word:'dates'},
    \       #{word:'datetimes'},
    \       #{word:'none'},
    \       #{word:'all'},
    \       #{word:'union'},
    \       #{word:'intersection'},
    \       #{word:'difference'},
    \       #{word:'selected_related'},
    \       #{word:'extra'},
    \       #{word:'defer'},
    \       #{word:'only'},
    \       #{word:'using'},
    \       #{word:'select_for_update'},
    \       #{word:'raw'},
    \   ],
    \   'method': [
    \       #{word:'get'},
    \       #{word:'create'},
    \       #{word:'get_or_create'},
    \       #{word:'update_or_create'},
    \       #{word:'bulk_create'},
    \       #{word:'bulk_update'},
    \       #{word:'count'},
    \       #{word:'in_bulk'},
    \       #{word:'iterator'},
    \       #{word:'latest'},
    \       #{word:'earliest'},
    \       #{word:'first'},
    \       #{word:'last'},
    \       #{word:'aggregate'},
    \       #{word:'exists'},
    \       #{word:'update'},
    \       #{word:'delete'},
    \       #{word:'as_manager'},
    \       #{word:'explain'},
    \   ],
    \   'lookup': [
    \       #{word:'exact'},
    \       #{word:'iexact'},
    \       #{word:'contains'},
    \       #{word:'icontains'},
    \       #{word:'in'},
    \       #{word:'gt'},
    \       #{word:'gte'},
    \       #{word:'lt'},
    \       #{word:'lte'},
    \       #{word:'startswith'},
    \       #{word:'istartswith'},
    \       #{word:'endswith'},
    \       #{word:'iendswith'},
    \       #{word:'range'},
    \       #{word:'date'},
    \       #{word:'year'},
    \       #{word:'iso_year'},
    \       #{word:'month'},
    \       #{word:'day'},
    \       #{word:'week'},
    \       #{word:'pk'},
    \   ],
    \}
endfun

let s:user_models = {}
function! django#objects#user_models(user_models)
    let s:user_models = a:user_models
endfun

function! django#objects#Model__Meta()
    return {
    \   'attributes': [
    \       #{word:'abstract', menu:"'bool'",
    \           info:'If abstract = True, this model will be an abstract base class.'},
    \       #{word:'app_label', menu:"'str'",
    \           info:"If a model is defined outside of an application in INSTALLED_APPS,\n"
    \               ."it must declare which app it belongs to:\n"},
    \       #{word:'db_table', menu:"'str'",
    \           info:"The name of the database table to use for the models:\n"
    \               ."\tdb_table='musice_album'\n"
    \               ."Default table name is `appname_ModelName`\n"
    \               ."$ python manage.py startapp bookstore\n"
    \               .">>> class Book(models.Model)\n"
    \               ."=> table name is: 'bookstore_book'"},
    \       #{word:'db_tablespace', menu:"'str'",
    \           info:"The name of the database tablespace to use for\n"
    \               ."this model. The default is the project's\n"
    \               ."DEFAULT_TABLESPCE setting, if set. If the backend\n"
    \               ."doesn't support tablespaces, this option is ignored."},
    \       #{word:'default_manager_name', menu:"'str'",
    \           info:"The name of the manager to use for the model's _default_manager"},
    \       #{word:'default_related_name'},
    \       #{word:'get_lastest_by'},
    \       #{word:'managed'},
    \       #{word:'order_with_respect_to'},
    \       #{word:'ordering'},
    \       #{word:'permissions'},
    \       #{word:'default_permissions'},
    \       #{word:'proxy'},
    \       #{word:'required_db_features'},
    \       #{word:'required_db_vendor'},
    \       #{word:'select_on_save'},
    \       #{word:'indexes'},
    \       #{word:'unique_together'},
    \       #{word:'index_together'},
    \       #{word:'constraints'},
    \       #{word:'verbose_name'},
    \       #{word:'verbose_name_plural'},
    \   ]
    \}
endfun

