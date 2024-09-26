module Markita
class Base < Sinatra::Base
  set sessions: true
  set bind: OPTIONS.bind || BIND
  set port: OPTIONS.port || PORT
  set server: SERVER
  if [SSL_CERTIFICATE, SSL_PRIVATE_KEY].all?{File.exist?_1}
    set server_settings: {
      SSLEnable: true,
      SSLVerifyClient: OpenSSL::SSL::VERIFY_NONE,
      SSLCertificate: OpenSSL::X509::Certificate.new(File.read SSL_CERTIFICATE),
      SSLPrivateKey:  OpenSSL::PKey::RSA.new(File.read SSL_PRIVATE_KEY)
    }
  end

  def self.run!
    super do |server|
      puts "#{$0}-#{VERSION}"
      puts "Sinatra-#{Sinatra::VERSION} using #{server.class}"
    end
  end

  get PAGE_KEY do |key|
    filepath = File.join ROOT, key+'.md'
    raise Sinatra::NotFound unless File.exist? filepath
    Markdown.new(key).filepath filepath
  end

  get SEND_FILE do |path|
    pass unless params.length==1 &&
                (filepath=File.join ROOT, path) &&
                File.exist?(filepath)
    send_file filepath
  end

  get '/' do
    filepath = File.join ROOT, 'index.md'
    if File.exist? filepath
      Markdown.new('index').filepath filepath
    else
      redirect '/about.html' unless OPTIONS.no_about
      raise Sinatra::NotFound
    end
  end

  not_found do
    NOT_FOUND
  end
end
end
