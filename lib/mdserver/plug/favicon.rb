module MDServer
class Base < Sinatra::Base
  HEADER_LINKS << %Q(  <link rel="icon" type="image/x-icon" href="/favicon.ico">\n)
  module Favicon
    ICO = File.exist?(_=File.join(ROOT, 'favicon.ico')) ?
          File.read(_) :
          File.read(File.join(APPDATA, 'favicon.ico'))
  end

  get '/favicon.ico' do
    headers 'Content-Type' => 'image/x-icon'
    Favicon::ICO
  end
end
end
