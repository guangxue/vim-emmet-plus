let s:options = [
\   #{word:'null', menu:'bool',
\       info:'Django will store empty values as NULL in the database.'},
\   #{word:'blank', menu:'bool',
\       info: 'The field is allowed to be blank.'},
\   #{word:'choices', menu:'tuple',
\       info:'A sequence consisting itself of iterbles exactly tow items to use as choices for this field.'},
\   #{word:'db_column', menu: 'str',
\       info:"The name of the database column to use for this field.\n"
\           ."If this isn't given, Django will use this field's name.\n"},
\   #{word:'db_index', menu:"'True'", info:"If True, a database index will be created for this field."},
\   #{word:'db_tablespace', menu:'str', info:""},
\   #{word:'default', menu:'str',
\       info:"The default value for the field. This can be value\n"
\           ."or a callable object. If callable it will be called\n"
\           ."every time a new object is created.\n\n"
\           ."def contanct_default():\n"
\           ."\treturn {\"email\": \"to1@example.com\"}\n\n"
\           ."contact_info = JSONField(\"ContactInfo\", default=contact_default)\n"},
\   #{word:'editable', menu:'bool',
\       info:"If `False`, the field will not be displayed in the admin\n"
\           ."or any other `ModelForm`. They are also skipped during\n"
\           ."model validation. Default is `True`."},
\   #{word:'error_messages', menu:'str', info:''},
\   #{word:'help_text', menu:'str', info:''},
\   #{word:'primary_key', menu:'str', info:''},
\   #{word:'unique', menu:'str', info:''},
\   #{word:'unique_for_date', menu:'', info:''},
\   #{word:'unique_for_month', menu:'', info:''},
\   #{word:'unique_for_year', menu:'', info:''},
\   #{word:'verbose_name', menu:'', info:''},
\   #{word:'validators', menu:'', info:''},
\]
let s:max_length=[
\    #{word:'max_length', menu:'', info:''},
\]
let s:datefd=[
\    #{word:'auto_now', menu:"bool", info:''},
\    #{word:'auto_now_add', menu:"bool", info:''},
\]

let s:decimalfd=[
\    #{word:'max_digits', menu:"int",
\           info:'<required>\nThe maximum number of digits allowed in the number. '
\               .'Note: this number must be greater than or equal to `decimal_places`'},
\
\    #{word:'decimal_places', menu:"int", info:"<required>\nThe number of decimal places to store with the number."},
\]

let s:filefd=[
\    #{word:'upload_to', menu:"str|callable",
\       info:"---\n"
\           ."{FileField.upload_to}\n"
\           ."\t# file will be uploaded to MEDIA_ROOT/uploads\n"
\           ."\tupload = models.FileFiled(upload_to='uploads/')\n"
\           ."\t# or...\n"
\           ."\t# file will be saved to MEDIA_ROOT/uploads/2015/01/30\n"
\           ."\tupload = models.FileField(upload_to='uploads/%Y/%m/%d/')\n\n"
\           ."`upload_to` may also be a callable, such as a function.\n\n"
\           ."def user_diretory_path(instance, filename)\n"
\           ."\t# file will be uploaded to MEDIA_ROOT/user_<id>/<filename>\n"
\           ."\treturn f'user_{instance.user.id}/{filename}'\n\n"
\           ."class MyModel(models.Model):\n"
\           ."\tupload = models.FileField(upload_to=user_directory_path)\n"
\           ."---"},
\    #{word:'max_length=100', menu:"int", info:''},
\]

let s:fpathfd = [
\  #{word:'path', menu:'str',
\       info:"<required>\nThe absolute filesystem path to a directory from which "
\           ."this FilePathField should get its choices. Example: \"/home/images\"\n\n"
\           ."FilePathField(path=\"/home/images\", match=\"foo.*\", recursive=True)\n"
\           ."...will match /home/images/foo.png but not /home/images/foo/bar.png "
\           ."because the match applies to the base filename(foo.png and bar.png)"},
\  #{word:'match', menu:'str',
\       info:"<optional> A regular expression, as a string, that FilePathField will "
\           ."use to filter filenames. Not that the regex will be applied "
\           ."to the base filename, not the full path. Example: \"foo.*\.text$\" "
\           ."which will match a file called foo23.txt but not bar.txt for foo23.png"},
\   #{word:'recursive', menu:'bool',
\       info:"<optional> Either True or False. Default is False. Specifies whether all subdirectories "
\           ."of path should be included."},
\   #{word:'allow_files', menu:'bool',
\       info:"<optional> Either True or False. Default is True. Specifies whether "
\           ."files in the specified location should be included. Either "
\           ."this or allow_folder must be True."},
\   #{word:'allow_folder', menu:'bool',
\       info:"<optional> Either True or False. Default is False. Specifies whether "
\           ."folder in the specified location should be included. "
\           ."Either this or `allow_files` must be True"},
\]

let s:imagefd = [
\   #{word: 'upload_to', menu:'str',
\       info:'Inherits all attributes and methods from FileField, but '
\           ."also validates that the uploaded object is valid image."},
\   #{word: 'height_field', menu:'',
\       info:"Name of model field which will be auto-populated with "
\           ."the height of the image each time model instance is saved."},
\   #{word: 'width_field', menu:'',
\       info:"Name of model field which will be auto-populated with "
\           ."the width of the image each time model instance is saved."},
\]

let s:ipfd = [
\   #{word:'protocol', menu:"'both'",
\       info:"Limits valid inputs to the specified protocol.\n"
\           ."Accepted values are 'both'(default), 'IPv4' or 'IPv6'\n"
\           ."Matching is case insensitive."},
\   #{word:'unpack_ipv4', menu:"'False'",
\       info:"Unpacks IPv4 mapped addresses like ::ffff:192.0.2.1\n"
\           ."If this option is enabled that address would be unpacked\n"
\           ."to 192.0.2.1. Default is disabled. Can only be used when\n"
\           ."protocol is set to 'both'"},
\]

let s:jsonfd = [
\   #{word:'encoder', menu:'',
\       info:"An optional `json.JSONEncoder` subclass to serialize\n"
\           ."data types not suppported by the standard JSON serializer\n"
\           ."(e.g. datetime.datetime or UUID). For example, you can use\n"
\           ."the `DjangoJSONEncoder ` class."},
\   #{word:'decoder', menu:'',
\       info:"An optional json.Decoder subclass to deserialize the\n"
\           ."value retrieved from the database."},
\]
let s:models = {
\   'all': django#db#models#import#all(),
\   'subclass':[
\       #{word:'AutoField', icase:'1', user_data:[]},
\       #{word:'BigIntegerField',icase:'1',user_data:[]},
\       #{word:'BooleanField',icase:'1',user_data:[]},
\       #{word:'CharField',icase:'1', user_data: s:max_length},
\       #{word:'DateField',icase:'1', user_data: s:datefd},
\       #{word:'DateTimeField',icase:'1', user_data: s:datefd},
\       #{word:'DecimalField',icase:'1', user_data: s:decimalfd,
\           info:"A fixed-precision decimal number, represented in\n"
\               ."Python by a `Decimal` instance. It validates the\n"
\               ."input using `DecimalValidator`.\n"
\               ."Has two <required> arguments."},
\       #{word:'DurationField',icase:'1', user_data:[],
\           info:"A field for storing period of time - modeled in Python by `timedelta`\n"
\               ."When used on PostgreSQL, the date type used in a interval and on\n"
\               ."Oracle data type is `INTERVAL DAY(9) TO SECOND(6)`. Otherwise\n"
\               ."a `bigint` of microseconds is used."},
\       #{word:'EmailField',icase:'1', user_data:['max_length=254'],
\           info:"A CharField that checks that the value is\na valid email address using `EmailValidator`"},
\       #{word:'FileField',icase:'1', user_data: s:filefd },
\       #{word:'FilePathField',icase:'1', user_data: s:fpathfd },
\       #{word:'FloatField',icase:'1', user_data:[] },
\       #{word:'ImageField', info:"<Requires the `Pillow` libray>", icase:'1', user_data: s:imagefd },
\       #{word:'IntegerField',icase:'1', user_data:[] },
\       #{word:'GenericIPAddressField', icase:'1', user_data: s:ipfd,
\           info:"An IPv4 or IPv6 address, in string format\n"
\               ."(e.g. 192.0.2.30 or 2a02:42fe::4)\n"
\               ."The default form widget for this field is a `TextInput`"},
\       #{word:'JSONField', icase:'1', menu:'', user_data: s:jsonfd,
\           info:"A field for storing JSON encoded data. In Python the data\n"
\               ."is represented in its Python native format: dictionaries,\n"
\               ."lists, strings, numbers, booleans and None."},
\       #{word:'PositiveBigIntegerField', icase:'1', user_data:[], info:"Values from 0 to 9223372036854775807"},
\       #{word:'PositiveIntegerField',icase:'1', user_data:[], info:"Values from 0 to 2147483647"},
\       #{word:'PositiveSmallField',icase:'1', user_data:[], info:"Values from 0 to 32767"},
\       #{word:'SlugField',icase:'1', user_data:[#{word:'max_length', menu:"'50'"}],
\           info:"It is often useful to automatically prepopulate a SlugField\n"
\               ."based on the value of some other value. You can do ths\n"
\               ."automatically in the admin using `prepopulated_fields`.\n\n"
\               ."Implies setting `Field.db_index` to True\n"
\               ."It use `validate_slug` or `validate_unicode_slug` for validation."},
\       #{word:'SmallAutoField', icase:'1', menu:'', user_data:[]},
\       #{word:'SmallIntegerField', icase:'1', menu:'', user_data:[], info:"from -32768 to 32767"},
\       #{word:'TextField', icase:'1', menu:'', user_data:[], info:""},
\       #{word:'TimeField', icase:'1', menu:'',
\           user_data:[#{word:'auto_now', menu:"'False'"}, #{word:'auto_now_add', menu:"'False'"}], 
\           info:"A time, represented by a datetime.time instance"},
\       #{word:'URLField', icase:'1', menu:'', user_data:[#{word:'max_length', menu:"'200'"}], info:""},
\       #{word:'UUIDField', icase:'1', menu:'', user_data:[],
\           info:"UUID are a good alternative to `AutoField` for primary_key.\n"
\               ."The database will not generate the UUID for you, so it is\n"
\               ."recommended to use `default`:\n\n"
\               ."import uuid\n"
\               ."from django.db import models\n\n"
\               ."class MyUUIDModel(models.Model):\n"
\               ."\tid=models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)"
\               },
\       #{word:'ForeignKey', icase:'1',
\           info:"A many-to-one relationship. Requires two positional arguments:\n"
\               ."the class to which the model is related and the `on_delete`\n"
\               ."option. To create a recursive raltionship - an object that\n"
\               ."has a many-to-one relationship with itself - \n"
\               ."\t`models.ForeignKey('self', models.CASCADE).`\n\n"
\               ."If you need to create a relationship on a model that has not\n"
\               ."yet been defined, you can use the name of the model as string,\n"
\               ."rather than the model object itself.\n\n"
\               ."manufacturer = models.ForeignKey(\n"
\               ."\tManufacturer',\n"
\               ."\ton_delete=models.CASCADE,\n"
\               .")\n\n"
\               ."class Manufacturer(models.Model):\n"
\               ."\tpass", user_data:[]},
\       #{word:'CASCADE',icase:'1', user_data:[]},
\       #{word:'PROTECT',icase:'1', user_data:[]},
\       #{word:'RESTRICT',icase:'1', user_data:[]},
\       #{word:'SET_NULL',icase:'1', user_data:[]},
\       #{word:'SET_DEFAULT',icase:'1', user_data:[]},
\       #{word:'SET',icase:'1', user_data:[]},
\   ],
\   'options':s:options,
\}

function! django#db#import#models()
    echom "from django#db#import#models()"
    return s:models
endfun

function! django#db#import#models__Model()
    return s:models
endfun

function! django#db#import#models__Manager()
    return {
    \   
    \}
endfun

function! django#db#import#Avg()
    
endfun

function! django#db#import#Count()
endfun

function! django#db#import#Max()
endfun

function! django#db#import#Min()
endfun

function! django#db#import#StdDev()
endfun
