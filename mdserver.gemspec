Gem::Specification.new do |s|

  s.name     = 'mdserver'
  s.version  = '1.0.210828'

  s.homepage = 'https://github.com/carlosjhr64/mdserver'

  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'

  s.date     = '2021-08-28'
  s.licenses = ['MIT']

  s.description = <<DESCRIPTION
A [Sinatra](http://sinatrarb.com) Markdown view server.

Uses [Kramdown](https://kramdown.gettalong.org/index.html) for the Markdown to
HTML conversion.
DESCRIPTION

  s.summary = <<SUMMARY
A [Sinatra](http://sinatrarb.com) Markdown view server.
SUMMARY

  s.require_paths = ['lib']
  s.files = %w(
README.md
bin/mdserver
data/favicon.ico
data/highlight.css
data/login_failed.html
data/login_form.html
data/not_found.html
lib/mdserver.rb
lib/mdserver/base.rb
lib/mdserver/config.rb
lib/mdserver/plug/about.rb
lib/mdserver/plug/favicon.rb
lib/mdserver/plug/highlight.rb
lib/mdserver/plug/login.rb
lib/mdserver/plug/plugs.rb
  )
  s.executables << 'mdserver'
  s.add_runtime_dependency 'help_parser', '~> 7.0', '>= 7.0.200907'
  s.add_runtime_dependency 'sinatra', '~> 2.1', '>= 2.1.0'
  s.add_runtime_dependency 'kramdown', '~> 2.3', '>= 2.3.1'
  s.add_runtime_dependency 'thin', '~> 1.8', '>= 1.8.1'

end
