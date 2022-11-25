Gem::Specification.new do |s|

  s.name     = 'markita'
  s.version  = '4.0.221124'

  s.homepage = 'https://github.com/carlosjhr64/markita'

  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'

  s.date     = '2022-11-24'
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
lib/markita/plug/navigation.rb
lib/markita/plug/plugs.rb
lib/markita/plug/readme.rb
lib/markita/preprocess.rb
  )
  s.executables << 'markita'
  s.add_runtime_dependency 'help_parser', '~> 8.0', '>= 8.0.210917'
  s.add_runtime_dependency 'rouge', '~> 4.0', '>= 4.0.0'
  s.add_runtime_dependency 'sinatra', '~> 3.0', '>= 3.0.3'
  s.add_runtime_dependency 'thin', '~> 1.8', '>= 1.8.1'
  s.requirements << 'ruby: ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [aarch64-linux]'

end
