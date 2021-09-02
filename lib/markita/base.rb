module Markita
class Preprocess
  def initialize(file)
    @file = (file.is_a? String)? StringIO.new(file) : file
    @regx = @template = nil
  end

  def gets
    if line = @file.gets
      case line
      when @regx
        line = @template if @template
        $~.named_captures.each do |name, value|
          line = line.gsub("&#{name.downcase};", value)
          line = line.gsub("&#{name.upcase};", CGI.escape(value))
        end
      when %r(^! regx = /(.*)/$)
        @regx = Regexp.new $1
        line = gets
      when %r(^! template = "(.*)"$)
        @template = $1+"\n"
        line = gets
      else
        @regx &&= (@template=nil)
      end
    end
    line
  end
end

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

  def Base.header(key)
    <<~HEADER
      <!DOCTYPE html>
      <html>
      <head>
        <title>#{key}</title>
      #{HEADER_LINKS}</head>
      <body>
    HEADER
  end

  def Base.footer
    <<~FOOTER
      </body>
      </html>
    FOOTER
  end

  def Base.page(key, f)
    file = Preprocess.new(f)
    html = ''
    html << Base.header(key)
    opt  = {}
    line = file.gets
    while line
      f = MARKDOWN.detect{|r,_|r.match? line}&.last || DEFAULT
      line = f[line, html, file, opt]
    end
    html << Base.footer
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
