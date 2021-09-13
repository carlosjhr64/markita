module Markita
class Base
  HEADER_LINKS << %Q(  <link rel="icon" type="image/x-icon" href="/favicon.ico">\n)
  module Favicon
    ICO = File.read PATH['favicon.ico']
  end

  get '/favicon.ico' do
    headers 'Content-Type' => 'image/x-icon'
    Favicon::ICO
  end
end
end
