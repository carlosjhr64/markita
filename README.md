# Markita

* [VERSION 2.0.210901](https://github.com/carlosjhr64/markita/releases)
* [github](https://www.github.com/carlosjhr64/markita)
* [rubygems](https://rubygems.org/gems/markita)

## DESCRIPTION

A [Sinatra](http://sinatrarb.com) Markdown server.

Uses [Kramdown](https://kramdown.gettalong.org/index.html) for the Markdown to
HTML conversion.

## INSTALL
```shell
$ gem install markita
```
## HELP
```shell
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

* Check(Ballot) boxes for task lists
* Image placement hints
* One line forms
* Template substitutions
* ONLY SERVES MARKDOWN PAGES:`/**/*.md`(omit extension `.md` in the url)
* ONLY SERVES PNG and GIF IMAGES: `/**/*.png`, and `/**/*.gif`
* See [`lib/markita/plug`](lib/markita/plug) and [`/plug`](https://github.com/carlosjhr64/markita/tree/main/plug) for examples of plugins

Optionally:

* Place your custom `/favicon.ico`
* Place your custom `/highlight.css`
* Place `/.cert.crt` and `/.pkey.pem` for SSL(https)
* Place `sha256sum` of site's password in `/.valid-id`

## HOW-TOs

### Set site password:
```shell
$ # Assuming ~/vimwiki is your site's root...
$ echo -n '<SitePasswordHere>' | sha256sum | grep -o '^\w*' > ~/vimwiki/.valid-id
```
### Set site custom favicon, css, not found page, and login form and fail page:
```shell
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
```shell
$ # Assuming ~/vimwiki with a site password set...
$ markita --allowed=127.0.0.1
./bin/markita-1.0.210826
== Sinatra (v2.1.0) has taken the stage on 8080 for development with backup from Thin
```
### Ballot boxes
```txt
- [ ] This is an emty ballot box
- [x] This is a checked ballot box
```
### Image placement hints:
```txt
Left and right spaces of the alternate text of an image hints placement.
The following image will be placed centered.

![ Centered Image ](/img/image.png)

![Left Floating ](/img/image.png)
The above specified image will float left.

![ Right Floating](/img/image.png)
The above specified image will float right.
```
### One line forms
```txt
Note the strict use of space!
This will do a get method form:

Google:[q] (https://www.google.com/search)

Due to the password field, this will do a post method form:

Username:[user] Password:[*pwd] (/login.html)

```
### Template substitutions
```txt
In the template string, uppercase keys are CGI escaped:

<!-- template: "* [&query;](https://www.google.com/search?q=&QUERY;)" -->
<!-- regx: /^\* (?<query>.*)$/ -->
* Grumpy Cat
* It's over 9000!

The substitutions are active until the end of the block.
If template is not provided, the line itself will be the template.
```
### Escaping HTML until after markdown's conversion
```

!-- <table><tr><td> --

# Left
1. One
2. Two
3. Three

!-- </td><td> --

# Right
* A
* B
* C

!-- </td></tr></table> --

```
### Adding plugs
```
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
