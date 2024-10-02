Gem::Specification.new do |s|
  ## INFO ##
  s.name     = 'markita'
  s.version  = '5.0.241001'
  s.homepage = 'https://github.com/carlosjhr64/markita'
  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'
  s.date     = '2024-10-02'
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
  s.add_runtime_dependency 'help_parser', '~> 9.0', '>= 9.0.240926'
  s.add_runtime_dependency 'rouge', '~> 4.4', '>= 4.4.0'
  s.add_runtime_dependency 'sinatra', '~> 4.0', '>= 4.0.0'
  s.add_runtime_dependency 'webrick', '~> 1.8', '>= 1.8.2'
  s.add_development_dependency 'colorize', '~> 1.1', '>= 1.1.0'
  s.add_development_dependency 'cucumber', '~> 9.2', '>= 9.2.0'
  s.add_development_dependency 'nokogiri', '~> 1.16', '>= 1.16.7'
  s.add_development_dependency 'parser', '~> 3.3', '>= 3.3.5'
  s.add_development_dependency 'rubocop', '~> 1.66', '>= 1.66.1'
  s.add_development_dependency 'test-unit', '~> 3.6', '>= 3.6.2'
  s.requirements << 'egrep: 3.6'
  s.requirements << 'git: 2.30'
  s.required_ruby_version = '>= 3.3'
end
