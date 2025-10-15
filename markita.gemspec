Gem::Specification.new do |s|
  ## INFO ##
  s.name     = 'markita'
  s.version  = '6.0.251015'
  s.homepage = 'https://github.com/carlosjhr64/markita'
  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'
  s.date     = '2025-03-28'
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
    lib/markita/markdown/attributes.rb
    lib/markita/markdown/blockquote.rb
    lib/markita/markdown/code.rb
    lib/markita/markdown/code_block.rb
    lib/markita/markdown/definitions.rb
    lib/markita/markdown/embed.rb
    lib/markita/markdown/empty.rb
    lib/markita/markdown/fold.rb
    lib/markita/markdown/footnotes.rb
    lib/markita/markdown/form.rb
    lib/markita/markdown/heading.rb
    lib/markita/markdown/horizontal_rule.rb
    lib/markita/markdown/image.rb
    lib/markita/markdown/inline.rb
    lib/markita/markdown/list.rb
    lib/markita/markdown/markup.rb
    lib/markita/markdown/script.rb
    lib/markita/markdown/split.rb
    lib/markita/markdown/table.rb
    lib/markita/plug/about.rb
    lib/markita/plug/favicon.rb
    lib/markita/plug/highlight.rb
    lib/markita/plug/login.rb
    lib/markita/plug/navigation.rb
    lib/markita/plug/plugs.rb
    lib/markita/plug/readme.rb
    lib/markita/preprocess.rb
    lib/markita/refinement.rb
    lib/markita/requires.rb
  ]
    s.executables << 'markita'
  ## REQUIREMENTS ##
  s.add_runtime_dependency 'colorize', '~> 1.1', '>= 1.1.0'
  s.add_runtime_dependency 'help_parser', '~> 9.0', '>= 9.0.240926'
  s.add_runtime_dependency 'rouge', '~> 4.5', '>= 4.5.1'
  s.add_runtime_dependency 'sinatra', '~> 4.1', '>= 4.1.1'
  s.add_runtime_dependency 'webrick', '~> 1.9', '>= 1.9.1'
  s.required_ruby_version = '>= 3.4'
end
