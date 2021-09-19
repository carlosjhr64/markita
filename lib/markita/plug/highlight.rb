module Markita
class Base
  HEADER_LINKS << %Q(  <link rel="stylesheet" href="/highlight.css" type="text/css">\n)
  module Highlight
    theme = OPTIONS&.theme || 'base16.light'
    CSS = Rouge::Theme.find(theme)&.render(scope: '.highlight')
    raise "Can't find Rouge Theme "+theme  unless CSS
  end

  get '/highlight.css' do
    headers 'Content-Type' => 'text/css'
    Highlight::CSS
  end
end
end
