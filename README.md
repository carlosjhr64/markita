# MDServer

* [VERSION 1.0.210827](https://github.com/carlosjhr64/mdserver/releases)
* [github](https://www.github.com/carlosjhr64/mdserver)
* [rubygems](https://rubygems.org/gems/mdserver)

## DESCRIPTION

A [Sinatra](http://sinatrarb.com) Markdown view server.

Uses [Kramdown](https://kramdown.gettalong.org/index.html) for the Markdown to
HTML conversion, and [Rouge](http://rouge.jneen.net) for the CSS/highlight.

## INSTALL
```shell
$ gem install mdserver
```
## HELP
```shell
$ mdserver --help
Usage:
  mdserver [:options+]
Options:
  --root=DIRECTORY       ~/vimwiki
  --bind=BIND            0.0.0.0
  --port=PORT            8080
  --theme=THEME          base16.light
  --allowed=IPS          127.0.0.1
Types:
  DIRECTORY /^~?[\/\w\.]+$/
  BIND      /^[\w\.]+$/
  PORT      /^\d+$/
  THEME     /^[\w\.]+$/
  IPS       /^[\d\.\,]+$/
```
## FEATURES

* Check(Ballot) boxes for task lists
* Image placement hints
* One line forms
* Template substitutions
* ONLY SUPPORTS /**/MARKDOWNs
* ONLY SUPPORTS /img/PNGs

Optionally:

* Place your custom `/favicon.ico`
* Place `/.cert.crt` and `/.pkey.pem` for SSL(https)
* Place `sha256sum` of site's password in `/.valid-id`

## HOW-TOs

### Set site password:
```shell
$ # Assuming ~/vimwiki is your site's root...
$ echo -n '<SitePasswordHere>' | sha256sum | grep -o '^\w*' > ~/vimwiki/.valid-id
```
### Set site custom favicon:
```shell
$ # Assuming ~/vimwiki is your site's root...
$ cp /path-to/custom/favicon.ico ~/vimwiki/favicon.ico
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
$ mdserver --allowed=127.0.0.1
./bin/mdserver-1.0.210826
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
This will do a get method form:

Google:[q](https://www.google.com/search)

Due to the passowrd field, this will do a post method form:

Username:[user] Password:[*pwd](/login.html)
```
### Template substitutions
```txt
In the template string, uppercase keys are CGI escaped:

<!-- template: "* [&query;](https://www.google.com/search?q=&QUERY;)" -->
<!-- regx: /^\* (<?query>.*)$/ -->
* Grumpy Cat
* It's over 9000!

The substitutions are active until the end of the block.
If template is not provided, the line itself will be the template.
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
