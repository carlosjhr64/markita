# Markita

* [VERSION 2.0.210904](https://github.com/carlosjhr64/markita/releases)
* [github](https://www.github.com/carlosjhr64/markita)
* [rubygems](https://rubygems.org/gems/markita)

## DESCRIPTION

A Sinatra Markdown server.

With many extra non-standard features.

## INSTALL
```console
$ gem install markita
```
## HELP
```console
$ markita --help
Usage:
  markita [:options+]
Options:
  --root=DIRECTORY 	 ~/vimwiki
  --bind=BIND      	 0.0.0.0
  --port=PORT      	 8080
  --allowed=IPS
  --no_about
  --no_favicon
  --no_highlight
  --no_login
  --no_plugs
Types:
  DIRECTORY /^~?[\/\w\.]+$/
  BIND      /^[\w\.]+$/
  PORT      /^\d+$/
  THEME     /^[\w\.]+$/
  IPS       /^[\d\.\,]+$/
# NOTE:
# Assuming site is in ~/vimwiki,
# when ~/vimwiki/.valid-id is set with a sha256sum of a password,
# that password will restrict the site.
# Allowed IPs bypass the need for site password
# when the site is accessed from those locations.
```
## FEATURES

### Ballot boxes

- [ ] Empty ballot
- [x] Marked ballot

Markdown:

    - [ ] Empty ballot
    - [x] Marked ballot

### Image placement

Markdown:

    ![ Centered Image ](/img/image.png)
    ![Left Floating ](/img/image.png)
    ![ Right Floating](/img/image.png)
    Image  centered above.
    Image to the left.
    Image to the right.
    And set a HR bar below.
    ---

### Forms

Markdown:

    A get method form without submit button on single field:
    ! Google:[q] (https://www.google.com/search)

    A post method form due to the password field with
    a submit button due to multiple fields:
    ! Username:[user] Password:[*pwd] (/login.html)

    A multi-line form with default entry and hidden field:
    ! Name:[user] (/register.html)
    ! Address:[address] (.)
    ! Code:[code=1234] [site=markita] (.)

### Template substitutions

Markdown:

    ! template = "* [&query;](https://www.google.com/search?q=&QUERY;)"
    ! regx = /^\* (?<query>.*)$/
    * Grumpy Cat
    * It's over 9000!

Template clears after first non-match.
Note: on upcased keys, value is CGI escaped.

### Split table

<table><tr><td>
<p>
Top left
</p>
</td><td>
<p>
Top center
</p>
</td><td>
<p>
Top right
</p>
</td></tr><tr><td>
<p>
Middle left
</p>
</td><td>
<p>
Middle center
</p>
</td><td>
<p>
Middle left
</p>
</td></tr><tr><td>
<p>
Bottom left
</p>
</td><td>
<p>
Bottom center
</p>
</td><td>
<p>
Bottom right
</p>
</td></tr></table>

Markdown:

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

### Inline links, code, bold, italic, strikes, and underline

<p>
The <b>bold</b> and <i>italics</i> <s>strikes</s> at <u>underlined</u>,
while a <a href="#Markita">link to #Markita</a>
sees the <code>~ code ~ "a*b*c"</code> to <a href="https://github.com">https://github.com</a>.
</p>

Markdown:

    The *bold* and "italics" ~strikes~ at _underlined_,
    while a [link to #Markita](#Markita)
    sees the `~ code ~ "a*b*c"` to [https://github.com].

### Lists: ordered, un-ordered, definitions

1. One
2. Two

* Point A
* Point B

: Word:
: Definition of the word
: Symbol:
: Usage for the symbol

Markdown:

    1. One
    2. Two

    * Point A
    * Point B

    : Word:
    : Definition of the word
    : Symbol:
    : Usage for the symbol

### Block-quote

Like Hamlet says...
> To be or not to be...
> That is the question!

Markdown:

    Like Hamlet says...
    > To be or not to be...
    > That is the question!

### Code
```ruby
def wut
  puts "Wut?"
end
```
Markdown:

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

Markdown:

    | Integer | Float | Symbol | Word          |
    | ------: | ----: | :----: | :------------ |
    |       1 |   1.0 |   $    | The word      |
    |    1234 |  12.3 |   &    | On the street |

### Attributes

{: style="color: blue;"}
You can set the attributes for most blocks.

Markdown:

    {: style="color: blue;"}
    You can set the attributes for most blocks.

### Embed text

!> /img/markita.txt

Markdown:

    !> /img/markita.txt

Must be a `*.txt` file.
Useful for ASCII art.

### Emojis

I :heart: to :laughing:!

Markdown:

    I :heart: to :laughing:!

### Footnotes

There once was a man from Nantucket[^1]  
Who kept all his cash[^2] in a bucket.  
But his daugter, named Nan,  
Ran away with a man  
And as for the bucket, Natucket.[^3]

[^1]: Nantucket is an island in the U.S. state of Massachusetts.
[^2]: Cash is money in currency.
[^3]: Read as "Nan took it."

Markdown:

    There once was a man from Nantucket[^1]  
    Who kept all his cash[^2] in a bucket.  
    But his daugter, named Nan,  
    Ran away with a man  
    And as for the bucket, Natucket.[^3]

    [^1]: Nantucket is an island in the U.S. state of Massachusetts.
    [^2]: Cash is money in currency.
    [^3]: Read as "Nan took it."

## HOW-TOs

### Set site password:
```console
$ # Assuming ~/vimwiki is your site's root...
$ echo -n '<SitePasswordHere>' | sha256sum | grep -o '^\w*' > ~/vimwiki/.valid-id
```
### Set site custom favicon, css, not found page, and login form and fail page:
```console
$ # Assuming ~/vimwiki is your site's root...
$ # Note that you'll have to restart the server on any change to these:
$ cp /path-to/custom/favicon.ico ~/vimwiki/favicon.ico
$ cp /path-to/custom/highlight.css ~/vimwiki/highlight.css
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

Copyright 2021 CarlosJHR64

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
