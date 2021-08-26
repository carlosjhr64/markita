# MDServer

* [VERSION 1.0.210826](https://github.com/carlosjhr64/mdserver/releases)
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
