module MDServer
class Base < Sinatra::Base
  module Favicon
    ICO = File.exist?(_=File.join(ROOT, 'favicon.ico')) ?
          File.read(_) :
          File.read(File.join(APPDIR, 'data/favicon.ico'))
  end

  get '/favicon.ico' do
    headers 'Content-Type' => 'image/x-icon'
    Favicon::ICO
  end
end
end

