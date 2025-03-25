# frozen_string_literal: true

# NOTE: Only for password protected personal website as anyone can trigger this.
module Markita
  # Base class for Sinatra
  class Base
    get '/restart.html' do
      Thread.new do
        sleep 1
        Kernel.exec($PROGRAM_NAME, *ARGV)
      end
      <<~RESTART
        <!DOCTYPE html>
        <html>
        <head><title>restart</title></head>
        <body>
        <h1>MDServer restart</h1>
        <pre>#{$PROGRAM_NAME} #{ARGV.join(' ')}</pre>
        </body>
        </html>
      RESTART
    end
  end
end
