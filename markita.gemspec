Gem::Specification.new do |s|

  s.name     = 'markita'
  s.version  = '3.0.210906'

  s.homepage = 'https://github.com/carlosjhr64/markita'

  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'

  s.date     = '2021-09-06'
  s.licenses = ['MIT']

  s.description = <<DESCRIPTION
A Sinatra Markdown server.

With many extra non-standard features.
DESCRIPTION

  s.summary = <<SUMMARY
A Sinatra Markdown server.
SUMMARY

  s.require_paths = ['lib']
  s.files = %w(
README.md
bin/markita
data/emojis.tsv
data/favicon.ico
data/highlight.css
data/login_failed.html
data/login_form.html
data/not_found.html
lib/markita.rb
lib/markita/base.rb
lib/markita/config.rb
lib/markita/html.rb
lib/markita/markdown.rb
lib/markita/plug/about.rb
lib/markita/plug/favicon.rb
lib/markita/plug/highlight.rb
lib/markita/plug/login.rb
lib/markita/plug/plugs.rb
lib/markita/preprocess.rb
  )
  s.executables << 'markita'
  s.add_runtime_dependency 'help_parser', '~> 7.0', '>= 7.0.200907'
  s.add_runtime_dependency 'rouge', '~> 3.26', '>= 3.26.0'
  s.add_runtime_dependency 'sinatra', '~> 2.1', '>= 2.1.0'
  s.add_runtime_dependency 'thin', '~> 1.8', '>= 1.8.1'

end
