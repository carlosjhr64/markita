module Markita
class Base < Sinatra::Base
  set bind: OPTIONS&.bind || '0.0.0.0'
  set port: OPTIONS&.port || '8080'
  set sessions: true

  def Base.run!
    puts "#{$0}-#{VERSION}"
    super do |server|
      if ['.cert.crt', '.pkey.pem'].all?{ File.exist? File.join(ROOT, _1)}
        server.ssl = true
        server.ssl_options = {
          :cert_chain_file  => File.join(ROOT, '.cert.crt'),
          :private_key_file => File.join(ROOT, '.pkey.pem'),
          :verify_peer      => false,
        }
      end
    end
  end

  get PAGE_KEY do |key|
    filepath = File.join ROOT, key+'.md'
    raise Sinatra::NotFound  unless File.exist? filepath
    Markdown.new(key).filepath filepath
  end

  get SEND_FILE do |path|
    pass unless params.length==1 and
                filepath = File.join(ROOT, path) and
                File.exist?(filepath)
    send_file filepath
  end

  get '/' do
    redirect '/index'
  end

  not_found do
    NOT_FOUND
  end
end
end
