# Markita

* [VERSION 6.0.250327](https://github.com/carlosjhr64/markita/releases)
* [github](https://www.github.com/carlosjhr64/markita)
* [rubygems](https://rubygems.org/gems/markita)

## DESCRIPTION

A Sinatra Markdown server.

With many extra non-standard features.

## INSTALL
```console
$ gem install markita
```
* Required Ruby version: `>= 3.4`

## HELP
```console
$ markita --help
Usage:
  markita [:options+]
Options:
  --root=DIRECTORY 	 ~/vimwiki
  --bind=BIND      	 0.0.0.0
  --port=PORT      	 8080
  --theme=THEME    	 base16.light
  --allowed=IPS
  --no=PLUGS
Types:
  DIRECTORY /^~?[\/\w\.]+$/
  BIND      /^[\w\.]+$/
  PORT      /^\d+$/
  IPS       /^[\d\.\,]+$/
  THEME     /^[\w\.]+$/
  PLUGS    /^[\w\,]+$/
# NOTE:
# Assuming site is in ~/vimwiki,
# when ~/vimwiki/.valid-id is set with a sha256sum of a password,
# that password will restrict the site.
# Allowed IPs bypass the need for site password
# when the site is accessed from those locations.
# You can use the --no option to list plugins to disable.
```
## FEATURES

* `#` Headers with link anchors
* `>` Block-quotes nests up to level three
* &#96;&#96;&#96; Code section highlighted by [Rouge](https://github.com/rouge-ruby/rouge)
* PRE-forms on text starting with four spaces
* Tables
* Script section pass through starts with `^<script` and ends with `^</script>`
* HTML pass through on `/^<.*>$/` lines
* And more...

### Meta-data

* `$key` substitution to its metadata value in text
* If `Title` is set via meta-data, Javascript will set the page's title to that
* One can use numbers to reference long URLs
```markdown
--- # The hashtag disambiguates the horizontal rule(legal YAML comment).
Title: Markita
1: https://github.com/carlosjhr64/markita
name: Don Quixote de la Mancha
# You can also add to attributes here:
attributes: style="color: darkgreen;"
... # The end marker is needed to end the fold
[Markita](1)
Your name is $name.
```
### Horizontal rule
```markdown
---
```
### Attributes
```markdown
{: style="color: blue;"}
You can set the attributes for most blocks.
```
### Lists

One can nest lists up to 3 levels:
```markdown
{: style="color: red;"}{: style="color: green;"}{: style="color: blue;"}
1. One
2. Two
 * ABC
  - [ ] Empty ballot
  - [x] Marked ballot
 * XYZ
3. Three
```
### Definitions
```markdown
+ Word: Definition
+ Slang:
+ Define slang
```
### Code

    ```ruby
    def wut
      puts "Wut?"
    end
    ```

### Tables

| Integer | Float | Symbol | Word          |
| ------: | ----: | :----: | :------------ |
|       1 |   1.0 |   $    | The word      |
|    1234 |  12.3 |   &    | On the street |
```markdown
| Integer | Float | Symbol | Word          |
| ------: | ----: | :----: | :------------ |
|       1 |   1.0 |   $    | The word      |
|    1234 |  12.3 |   &    | On the street |
```
### Splits table

<table><tr><td>
<p> Top left </p>
</td><td>
<p> Top center </p>
</td><td>
<p> Top right </p>
</td></tr><tr><td>
<p> Middle left </p>
</td><td>
<p> Middle center </p>
</td><td>
<p> Middle left </p>
</td></tr><tr><td>
<p> Bottom left </p>
</td><td>
<p> Bottom center </p>
</td><td>
<p> Bottom right </p>
</td></tr></table>

```markdown
|:
Top left
|
Top center
|
Top right
:|:
Middle left
|
Middle center
|
Middle left
:|:
Bottom left
|
Bottom center
|
Bottom right
:|
```
### Image placement
```markdown
![:Centered Image:](/img/image.png)
![Left Floating:](/img/image.png)
![:Right Floating](/img/image.png)
Image  centered above.
Image to the left.
Image to the right.
```
### Image size
```markdown
![In alt text say 100x100](/img/image.png)
```
### Image link
```markdown
![Alt text](/img/image.png /href_to/page)
```
### Embed text
```markdown
!> /path-to/ascii_art.txt
```
Useful for ASCII art.
Unless an `*.html` file, the text is embedded in `pre` tags.
Further more unless a `*.txt` file, the text is embedded in `code` tags.

### Footnotes
```markdown
There once was a man from Nantucket[^1]  
Who kept all his cash[^2] in a bucket.  
But his daughter, named Nan,  
Ran away with a man  
And as for the bucket, Natucket.[^3]

[^1]: Nantucket is an island in the U.S. state of Massachusetts.
[^2]: Cash is money in currency.
[^3]: Read as "Nan took it."
```
### Forms
```markdown
A get method form without submit button on single field:
! Google:[q] (https://www.google.com/search)

A post method form with a password field
and a submit button due to multiple fields.
Note the `*` in front of `pwd` marking it as a password field,
and the ending `!` marking the route as a post:
! Username:[user] Password:[*pwd] (/login.html)!

A multi-line form with default entry and hidden field:
! Name:[user] [status="active"] (/register.html)
! Address:[address]
! Code:[code="1234"]

A selection list:
! Color:[color="Red","White","Blue"]

A submit button:
! [submit="Go!"]
```
### Template substitutions
```markdown
! regx = /^This (?<word>\w+)/
This cat is a pussy&word;.

! template = "* [&query;](https://www.google.com/search?q=&QUERY;)"
! regx = /^\* (?<query>.*)$/
* Grumpy Cat
* It's over 9000!
```
Template clears after first non-match.
Note: on upcased keys, value is CGI escaped.

### Inline links, code, bold, italic, strikes, and underline

The <b>bold</b> and <i>italics</i> <s>strikes</s> at <u>underlined</u>,
while a [link to #Markita](#Markita)
sees the `~ code ~ "a*b*c"` to https://github.com.
```markdown
The *bold* and "italics" ~strikes~ at _underlined_,
while a [link to #Markita](#Markita)
sees the `~ code ~ "a*b*c"` to https://github.com.
```
The inline links with optional title have the following syntax(with no double quotes):
```markdown
[link text](link title)
```
### Entity escapes

When you want to escape the inline substitutions or HTML tags, use backslash:

* &#92;&#60; &#92;&#62;  &#92;&#42; &#92;&#34; &#92;&#126; &#92;&#96; &#92;&#38; &#92;&#59; &#92;&#92;

### Emojis

I :heart: to :laughing:!
```markdown
I :heart: to :laughing:!
```
### Superscript and subscript

This is <sup>superscript</sup> and this is <sub>subscript</sub>.
```markdown
This is \^(superscript) and this is \(subscript).
```
### It's all Ruby!

Add your own custom features.

## HOW-TOs

### Set site password:
```console
$ # Assuming ~/vimwiki is your site's root...
$ echo -n '<SitePasswordHere>' | sha256sum | grep -o '^\w*' > ~/vimwiki/.valid-id
```
### Set site custom favicon, not found page, and login form and fail page:
```console
$ # Assuming ~/vimwiki is your site's root...
$ # Note that you'll have to restart the server on any change to these:
$ cp /path-to/custom/favicon.ico ~/vimwiki/favicon.ico
$ cp /path-to/custom/not_found.html ~/vimwiki/not_found.html
$ cp /path-to/custom/login_form.html ~/vimwiki/login_form.html
$ cp /path-to/custom/login_fail.html ~/vimwiki/login_fail.html
```
### Run site in https:
```
$ # Assuming ~/vimwiki is your site's root...
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout pkey.pem -out cert.crt
$ # Stuff happens... Answer all the dumb questions... then:
$ mv cert.crt ~/vimwiki/.cert.crt
$ mv pkey.pem ~/vimwiki/.pkey.pem
```
### Allow localhost to bypass password:
```console
$ # Assuming ~/vimwiki with a site password set...
$ markita --allowed=127.0.0.1
./bin/markita-1.0.210826
== Sinatra (v2.1.0) has taken the stage on 8080 for development with backup from Thin
```
### Adding plugs
```console
$ # Assuming ~/vimwiki
$ mkdir ~/viwiki/plug
$ # Then copy (or create) your plug there.
$ # For example:
$ GET https://raw.githubusercontent.com/carlosjhr64/markita/main/plug/todotxt.rb > ~/vimwiki/plug/todotxt.rb
```
## LICENSE

Copyright (c) 2025 CarlosJHR64

Permission is hereby granted, free of charge,
to any person obtaining a copy of this software and
associated documentation files (the "Software"),
to deal in the Software without restriction,
including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and
to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS",
WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## [CREDITS](CREDITS.md)
