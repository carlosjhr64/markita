module MDServer
class Base
  get '/restart.html' do
    Thread.new do
      sleep 1
      Kernel.exec($0, *ARGV)
    end
    <<~RESTART
      <!DOCTYPE html>
      <html>
      <head><title>restart</title></head>
      <body>
      <h1>MDSever restart</h1>
      <pre>#{$0} #{ARGV.join(' ')}</pre>
      </body>
      </html>
    RESTART
  end
end
end
