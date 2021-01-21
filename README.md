# vim-emmet-expand

An emmet-like plugin comes with auto pairs, snippet expanding and more. All triggered by pressing `Tab`
This plugin is for personal ***learning purpose only.*** **Support vim version 8.2+**

![screenshot](doc/demo.gif)

# Installation

If you interested in this plugin and would like to try this.
Use [vim-plug](https://github.com/junegunn/vim-plug), or other plugin manager you prefer. Following example
for vim-plug, you would place it in your .vimrc and run `:PlugInstall`

```vim
Plug 'guangxue/vim-emmet-expand'
```

## emmet features

### More accurate indentation


```html
    <body>
        <main>
            <p>div>p{item$}*6</p>
        </main>
    </body>
```

will expand to

```html
    <body>
        <main>
            <p><div>
                <p>item1</p>
                <p>item2</p>
                <p>item3</p>
                <p>item4</p>
                <p>item5</p>
                <p>item6</p>
            </div></p>
        </main>
    </body>
```

NOT TO:

```html
    <body>
        <main>
            <p><div>
    <p>item1</p>
    <p>item2</p>
    <p>item3</p>
    <p>item4</p>
    <p>item5</p>
    <p>item6</p>
</div></p>
        </main>
    </body>
```

### Parse {} properly

```django
h1{{{ post.title }}}+p.date{{{ post.published }} by {{ post.author }}}
```

```django
<!-- expand to  -->
<h1>{{ post.title }}</h1>
<p class="date">{{ post.published }} by {{ post.author }}</p>
```

Parse {} inside attributes:
```django
a[href='{{ post.get_absolute_url }}']{{{ post.title }}}
```

```django
<!-- expand to  -->
<a href="{{ post.get_absolute_url }}">{{post.title}}</a>
```

### Newlines (\n) and Tab(\t) has its meaning in {}

```django
div#content{\n\t\t{% block content %}\n\t\t{% endblock %}\n\t}
```

```django
<!-- expand to  -->
<div id="content">
    {% block content %}
    {% endblock %}
</div>
```

### Use Tab to jump next

```html
<div><img src="css/homepage.jpg|" alt=""></div>
```

will jump to next between tags, or ""

```html
<div><img src="css/homepage.jpg|" alt="|">|</div>
                         from ~^ to ~~~^to~^
```

**NOTE** When there are still some empty tags and quotes after current cursor, `Tab` will continue jumping instead of expanding abbreviation. Jump next will stop at last expanded line.

### CSS property value complete menu

```css
div {
    cur|<Tab>
}
```

will open a complete menu for you to choose property values.
use `k` for up selection , `j` for down selection.

### Bring back complete menu

When text before cursor is `CSS property` name ends with colon,
it will bring back complete menu automatically


## Snippets expansion with Tab

### Django snippets

```django
block|<Tab>
```

will expand to

```django
{% block %}
|
{% endblock %}
```

### Vimscript snippets

```vim
if|<Tab>
```

will expand to

```vim
if |
endif
```

```vim
sub|<Tab>
```

will expand to

```vim
" Press Tab to jump next
" next {pat} will be highlighted in Visual mode,
" to continue editing, press `c` to change text with curly brackets, and Tab to jump next.

substitute(|, {pat}, {sub}, '')
```


## Auto pair features

**('|' is cursor posistion)**

```ruby
Type: (
Get : (|)

When: |string
Type: '
GET : '|string

When in python file: def __str__|
Type: (
GET : def __str__(|):

When in django html: {|}
Type: %
GET : {% | %}

When: ''|
Type: '
GET : '''|'''

# auto-pairs for html tag
When <div class="header"|
Type: >
GET : <div class="header">|</div>

When : <div class="header">|</div>
Type : <BS>
GET  :  <div class="header"|
```

## Newlines

```ruby
When: {|}
Type: <CR>
GET : {
        |
    }

When: """string|"""
Type: <CR>
GET : """string
|
"""

When: return render(request, |)
Type: <CR>
GET : return render(request,
    |
)

```

## Experimental features

### Force inline elements indentation by prefix '\n'.

```html
div\n>button
```
will expand to

```html
<div>
    <button></button>
</div>
```

NOT TO

```html
<div><button></button></div>
```

### Semi-colon attributes

To expand attributes with different values, put different values inside backtick, and
separate each value with semi-colon, will get different attribute values.

```html
    select[id=size name=size]>option[value=`Small;Medium;Large`]{`Small;Medium;Large`}*3
```
Will expand to

```html
    <select id="size" name="size">
        <option value="Small">Small</option>
        <option value="Medium">Medium</option>
        <option value="Large">Large</option>
    </select>
```
NOT TO

```html
    <select id="size" name="size">
        <option value="`Small;Medium;Large`">`Small;Medium;Large`</option>
        <option value="`Small;Medium;Large`">`Small;Medium;Large`</option>
        <option value="`Small;Medium;Large`">`Small;Medium;Large`</option>
    </select>
```

## Comma appending.

```ruby
When: ',|'
Type: ,
Get : '|',

When: last line is 'text',
Type: '
Get : '|',
```


## Configuration

```vim
" let g:expand_{ft}_snippets = {'trigger': 'expanding_string'}
" Note: user defined snippets will overide existing snippets.
" Example:
let g:expand_css_snippets = {'bgk': 'background-color: #efefe${0};'}
let g:expand_html_snippets = {'ul5': 'ul>li*5'}

" vimscript snippet is disabled by default.
" Enabling by append following line.
let g:expand_vimscript = 1
```

## In progress..(More features to come)

- [ ] Emmet css expand syntax: m10 -> margin: 10px.
- [ ] Visual selection for emmet and text to wrap.
- [ ] Emmet climb up syntax ^.
- [ ] Improve css completion menu

This plugin still in progress... use it at your own risk. :smirk:

## License

MIT
