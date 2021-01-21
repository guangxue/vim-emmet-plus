let s:options = [
\   #{word: 'required', menu: 'Boolean',
\       info:'Boolean that specifies whether the fields is required. True by default.'},
\   #{word: 'widget', menu: '<class: Widget>',
\       info:'A Widget class, or instace of a Widget class, that should be used '
\           .'for this Field when displaying it. Each field has a default Widget '
\           .'that it will use if you do not specify this. '
\           .'In most cases, the default widget is TextInput.'},
\   #{word: "label=''", abbr:'label', menu: 'str',
\       info:'A verbose name for this field, for use in displaying '
\           .'this field in a form. By default, Django will use a "pretty" '
\           .'version of the form field name, if the Field is part of a Form.'},
\   #{word: 'initial', menu: 'str',
\       info:"A value to use in this Field's initial display. "
\           ."This value is *not* used as fallback if data "
\           ."isn't given."},
\   #{word: 'help_text', menu: '<class: dict>',
\       info:'An optional string to use as "help text" for this Field'},
\   #{word: 'error_messages', menu:'str',
\       info:'An optional dictionary to override the default message '
\           .'that the field will raise.'}
\]

let s:widgets = [
\   #{word: 'TextInput', icase:'1'},
\   #{word: 'NumberInput', icase:'1'},
\   #{word: 'EmailInput', icase:'1'},
\   #{word: 'URLInput', icase:'1'},
\   #{word: 'PasswordInput', icase:'1'},
\   #{word: 'HiddenInput', icase:'1'},
\   #{word: 'DateInput', icase:'1'},
\   #{word: 'DateTimeInput', icase:'1'},
\   #{word: 'TimeInput', icase:'1'},
\   #{word: 'Textarea', icase:'1'},
\   #{word: 'CheckboxInput', icase:'1'},
\   #{word: 'Select', icase:'1'},
\   #{word: 'NullBooleanSelect', icase:'1'},
\   #{word: 'SelectMultiple', icase:'1'},
\   #{word: 'RadioSelect', icase:'1'},
\   #{word: 'CheckboxMultiple', icase:'1'},
\   #{word: 'FileInput', icase:'1'},
\   #{word: 'ClearableFileInput', icase:'1'},
\   #{word: 'MultipleHiddenInput', icase:'1'},
\   #{word: 'SplitHiddenDateTimeWidget', icase:'1'},
\   #{word: 'SelectDateWidget', icase:'1'},
\]

let s:charfield = [
\ #{word: 'max_length=', abbr:'max_length', menu:'Int'},
\ #{word: 'min_length=', abbr:'min_length',menu:'Int'},
\ #{word: 'strip=', abbr:'strip', menu: 'Boolean'},
\ #{word: "empty_value=''", abbr:'empty_value', menu:'Str'},
\]

function! django#import#forms__Form()
    return {
    \   'subclass':[
    \       #{word:'BooleanField', icase:'1', user_data:[]},
    \       #{word:'CharField', icase:'1', user_data: s:charfield},
    \       #{word:'ChoiceField', icase:'1', user_data:[]},
    \       #{word:'TypedChoiceField', icase:'1', user_data:[]},
    \       #{word:'DateField', icase:'1', user_data:[]},
    \       #{word:'DateTimeField', icase:'1', user_data:[]},
    \       #{word:'DecimalField', icase:'1', user_data:[]},
    \       #{word:'DurationField', icase:'1', user_data:[]},
    \       #{word:'EmailField', icase:'1', user_data:[]},
    \       #{word:'FileField', icase:'1', user_data:[]},
    \       #{word:'FilePathField', icase:'1', user_data:[]},
    \       #{word:'FloatField', icase:'1', user_data:[]},
    \       #{word:'ImageField', icase:'1', user_data:[]},
    \       #{word:'JSONField', icase:'1', user_data:[]},
    \       #{word:'GenericIPAddressField', icase:'1', user_data:[]},
    \       #{word:'MultipleChoiceField', icase:'1', user_data:[]},
    \       #{word:'TypedMultipleChoiceField', icase:'1', user_data:[]},
    \       #{word:'NullBooleanField', icase:'1', user_data:[]},
    \       #{word:'RegexField', icase:'1', user_data:[]},
    \       #{word:'SlugField', icase:'1', user_data:[]},
    \       #{word:'TimeField', icase:'1', user_data:[]},
    \       #{word:'URLField', icase:'1', user_data:[]},
    \       #{word:'UUIDField', icase:'1', user_data:[]},
    \   ],
    \   'options': s:options,
    \   'widgets': s:widgets,
    \}
endfun
