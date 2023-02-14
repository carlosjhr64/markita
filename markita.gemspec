Gem::Specification.new do |s|
  ## INFO ##
  s.name     = 'markita'
  s.version  = '4.1.230214'
  s.homepage = 'https://github.com/carlosjhr64/markita'
  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'
  s.date     = '2023-02-14'
  s.licenses = ['MIT']
  ## DESCRIPTION ##
  s.summary  = <<~SUMMARY
    A Sinatra Markdown server.
  SUMMARY
  s.description = <<~DESCRIPTION
    A Sinatra Markdown server.
    
    With many extra non-standard features.
  DESCRIPTION
  ## FILES ##
  s.require_paths = ['lib']
  s.files = %w[
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
  ]
    s.executables << 'markita'
  ## REQUIREMENTS ##
  s.add_runtime_dependency 'help_parser', '~> 8.2', '>= 8.2.230210'
  s.add_runtime_dependency 'rouge', '~> 4.1', '>= 4.1.0'
  s.add_runtime_dependency 'sinatra', '~> 3.0', '>= 3.0.5'
  s.add_runtime_dependency 'thin', '~> 1.8', '>= 1.8.1'
  s.add_development_dependency 'colorize', '~> 0.8', '>= 0.8.1'
  s.add_development_dependency 'nokogiri', '~> 1.14', '>= 1.14.2'
  s.add_development_dependency 'parser', '~> 3.2', '>= 3.2.1'
  s.add_development_dependency 'rubocop', '~> 1.45', '>= 1.45.1'
  s.add_development_dependency 'test-unit', '~> 3.5', '>= 3.5.7'
  s.requirements << 'git: 2.30'
  s.requirements << 'ruby: 3.2'
end
