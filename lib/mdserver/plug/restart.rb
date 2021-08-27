module MDServer
class Base
  module Restart
    TIME = Time.now
  end

  get '/restart.html' do
    version = VERSION
    if File.mtime(__FILE__) > Restart::TIME
      version = 'Restarting...'
      Thread.new do
        sleep 1
        Kernel.exec(__FILE__)
      end
    end
    <<~RESTART
      <!DOCTYPE html>
      <html>
      <head><title>restart</title></head>
      <body>
      <h1>#{version}</h1>
      </body>
      </html>
    RESTART
  end
end
end
