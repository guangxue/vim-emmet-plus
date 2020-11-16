function! django#apps#import#all()
    return ['apps', 'AppConfig']
endfun

function! django#apps#import#apps()
    let props = [
    \   #{word:'all_models', menu:"'defaultdict'",
    \       info:"Mapping of map labels => model names => model classes.\n"
    \           ."Every time a model is imported, ModelBase.__new__ calls\n"
    \           ."apps.register_model which creates an entry in all_models.\n"
    \           ."All imported models are registered, regardless of whether\n"
    \           ."they're defined in an installed applicaiton and whether the\n"
    \           ."registery has been populated. Since it isn't possible to\n"
    \           ."re-import a module safely(it could re-execute intialization code)\n"
    \           ."all_models is never overridden or reset."},
    \   #{word:'app_configs', menu:"'{}'",
    \       info:"Mapping of labels to AppConfig instance for installed apps."},
    \   #{word:'stored_app_configs', menu:"'[]'",
    \       info:"Stack of app_configs. Used to store the current state in\n"
    \           ."`set_available_apps` and `set_installed_apps`."},
    \   #{word:'ready', menu:"'True'", info:"Boolean attribute is set to True\n"
    \       ."after the rigistry is fully populated and all AppConfig.ready() method are called."},
    \   #{word:'ready_event', menu:"'threading.Event()'", info:"For the auto-re-loader"},
    \   #{word:'populate', menu:"'installed_apps=()'",
    \       info:"Load application configurations and models.\n"
    \           ."Import each application module and then each\n"
    \           ."model module. It is thread-safe and idempotent,\n"
    \           ."but not re-entrant.", user_data:[#{word:'installed_apps', menu:"'()'"}]},
    \   #{word:'check_apps_ready'},
    \   #{word:'check_models_ready'},
    \   #{word:'get_app_config', info:"Import applications and returns an app config for\n"
    \                                ."the given label. Raise LookupError if no application\n"
    \                                ."exists with this label."},
    \   #{word:'get_models', user_data:[#{word:'include_auto_created', menu:"'False'"},
    \                           #{word:'include_swapped', menu:"'False'"}]},
    \]

    return {
    \   "props": props,
    \   "options": [],
    \}
endfun

function! django#apps#import#AppConfig()
    let attributes = [
    \   #{word:'name', menu:'<unique>',
    \       info:"Full Python path to the application, e.g. 'django.contrib.admin'\n"
    \           ."This attribut defines which application the configuartion\n"
    \           ."applies to. It must be set in all `AppConfig` subclasses.\n"
    \           ."It must be unique across a Django project."},
    \   #{word:'label', menu:'<unique>',
    \       info:"Short name for application, e.g. 'amdin'\n"
    \           ."This attribute allows relabeling an application\n"
    \           ."when two applications have conflicting labels. It\n"
    \           ."defaults to the last component of name. It should be\n"
    \           ."a valid Python identifier."},
    \   #{word:'verbose_name',
    \       info:"Human-readable name for the application. e.g. \"Administration\"\n"
    \           ."This attribute default to `label.title()`"},
    \   #{word:'path',
    \       info:"Filesystem path to the application directory,\n"
    \           ."e.g. 'usr/lib/python3.9/dist-packages/django/contrib/admin'\n"
    \           ."In most cases, Django can automatically detect and set this\n"
    \           ."but you can also provide an explicit override as a class\n"
    \           ."attribute on you `AppConfig` subclass. In few situations\n"
    \           ."this is required; for instance if the app package is a \n"
    \           ."namespace package with multiple paths."},
    \   #{word:'module', info:"Root module for the application, e.g.\n"
    \       ."<module 'django.contrib.admin'\nfrom 'django/contrib/admin/__init__.py'> "},
    \   #{word:'models_module', info:"Module containing the models, e.g.\n"
    \       ."<module 'django.contrib.admin.models' from\n'django/contrib/admin/models.py'> "},
    \]
    let methods = [
    \   #{word:'get_models',
    \       info:"Return an iterable of Model classes for this application"
    \           ."Requires the app registry to be fully populated"},
    \   #{word:'get_model', user_data:[#{word:'model_name'}, #{word:'require_ready'}]},
    \   #{word:'ready'},
    \]
    return {
    \   "attributes": attributes,
    \   "methods": methods,
    \}
endfun
