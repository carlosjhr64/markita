module MDServer
class Base < Sinatra::Base
  HEADER_LINKS << %Q(  <link rel="stylesheet" href="/highlight.css" type="text/css">\n)
  module Highlight
    CSS = File.exist?(_=File.join(ROOT, 'highlight.css')) ?
          File.read(_) :
          File.read(File.join(APPDATA, 'highlight.css'))
  end

  get '/highlight.css' do
    headers 'Content-Type' => 'text/css'
    Highlight::CSS
  end
end
end
