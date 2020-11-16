fun! django#db#models#import#all()
    return [
    \   'Aggregate', 'Avg', 'Count', 'Max', 'Min', 'StdDev', 'Sum', 'Variance',
    \   'CheckConstraint', 'Deferrable', 'UniqueConstranit',
    \   'Choices', 'IntegerChoices', 'TextChoices',
    \   'AutoField', 'BLANK_CHICE_DASH', 'BigAutoField', 'BigIntegerField', 'BinaryField',
    \   'BooleanField', 'CharField', 'CommaSeparatedIntegerField', 'DateField', 'DateTimeField',
    \   'DecimalField', 'DurationField', 'EmailField', 'Empty', 'Field', 'FilePathField',
    \   'FloatField', 'GenericIPAddressField', 'IntegerField', 'NOT_PROVIDED', 'NullBooleanField',
    \   'PositiveSmallIntegerField', 'SlugField', 'SmallAutoField', 'SmallIntegerField', 'TextField',
    \   'TimeField', 'URLField', 'UUIDField', 'Index',
    \   'ObjectDoesNotExist', 'signals', 'CASCADE', 'DO_NOTHING', 'PROTECT', 'Q', 'QuerySet',
    \   'Lookup', 'Transform', 'Manager', 'Model',
    \]
endfun

function! django#db#models#import#Lookup()
    return {
    \   'subattr': [#{word:'lookup_name'}],
    \   'submeth': [#{word:'as_sql', menu:'self, compiler, connection'}],
    \}
endfun
