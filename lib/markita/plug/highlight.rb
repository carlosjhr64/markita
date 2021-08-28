module Markita
class Base < Sinatra::Base
  HEADER_LINKS << %Q(  <link rel="stylesheet" href="/highlight.css" type="text/css">\n)
  module Highlight
    CSS = File.read PATH['highlight.css']
  end

  get '/highlight.css' do
    headers 'Content-Type' => 'text/css'
    Highlight::CSS
  end
end
end
