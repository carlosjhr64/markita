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

  DEFAULT = lambda do |line, html, file, _, _|
    html << line
    file.gets
  end

  def Base.page(key, f)
    html,opt,file,line = '',{},Preprocess.new(f),HTML.header(key)
    fct,md = nil,nil
    while line = (fct||DEFAULT)[line, html, file, opt, md]
      fct = nil
      Markdown::PARSER.each{|r,f| break if md=r.match(line) and fct=f}
    end
    html << HTML.footer
    html
  end

  get PAGE_KEY do |key|
    filepath = File.join ROOT, key+'.md'
    raise Sinatra::NotFound  unless File.exist? filepath
    File.open(filepath, 'r'){|f| Base.page key, f}
  end

  get IMAGE_PATH do |path, *_|
    send_file File.join(ROOT, path)
  end

  get '/' do
    redirect '/index'
  end

  not_found do
    NOT_FOUND
  end
end
end
