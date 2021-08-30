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

  def Base.header(key)
    <<-HEADER
<!DOCTYPE html>
<html>
<head>
  <title>#{key}</title>
#{HEADER_LINKS}</head>
<body>

    HEADER
  end

  def Base.footer
    <<-FOOTER

</body>
</html>
    FOOTER
  end

  def Base.process(text, procs=POSTPROCESS)
    val,string,_ = {},'',nil
    text.each_line do |line|
      line.chomp!
      case line
      when ''
        val.clear
      when %r(^<(p>)?!\p{Pd}+ (.*) \p{Pd}+(</p)?>$)
        directive = $2
        case directive
        when %r(^(\w+): "(.*)"$)
          val[$1.to_sym] = $2
        when %r(^(\w+): /(.*)/)
          val[$1.to_sym] = Regexp.new $2
        else
          $stderr.puts "Unrecognized directive: "+directive
        end
        next
      else
        # set line to IDontCare if IDontCare gets set
        line=_ if procs.detect{_=_1[line, val]}
      end
      string << line << "\n"
    end
    return string
  end

  def Base.page(key)
    Base.header(key) + yield + Base.footer
  end

  get PAGE_KEY do |key|
    filepath = File.join ROOT, key+'.md'
    raise Sinatra::NotFound  unless File.exist? filepath
    text = File.read(filepath).force_encoding('utf-8')
    Base.page(key){ Base.process markdown Base.process(text, PREPROCESS)}
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
