module MDServer
class Base < Sinatra::Base
  set views: ROOT
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
  <link rel="stylesheet" href="/highlight.css" type="text/css">
  <link rel="icon" type="image/x-icon" href="/favicon.ico">
</head>
<body>

    HEADER
  end

  def Base.footer
    <<-FOOTER

</body>
</html>
    FOOTER
  end

  def Base.pre_process(text)
    val,string,_ = {},'',nil
    text.each_line do |line|
      line.chomp!
      case line
      when ''
        val.clear
      when val[:regx]
        # Template/Substitutions
        line=_ if _=val[:template]
        $~.named_captures.each do |name, value|
          line = line.gsub("&#{name};", value)
          line = line.gsub("&#{name.upcase};", CGI.escape(value))
        end
      when %r(^<!-- (.*) -->$)
        directive = $1
        case directive
        when %r(^(\w+): "(.*)"$)
          val[$1.to_sym] = $2
        when %r(^(\w+): /(.*)/)
          val[$1.to_sym] = Regexp.new $2
        else
          $stderr.puts "Unrecognized directive: "+directive
        end
        next
      end
      string << line << "\n"
    end
    return string
  end

  def Base.post_process(text)
    string,_ = '',nil
    text.each_line do |line|
      line.chomp!
      case line
      when %r(^(\s*)<li>\[(x| )\] (.*)</li>$)
        # Task Lists
        s,x,item = $1,$2,$3
        li = (x=='x')?
          %q{<li style="list-style-type: '&#9745; '">} :
          %q{<li style="list-style-type: '&#9744; '">}
        line = s+li+item+"</li>"
      when %r(^<p>(\w+:\[\*?\w+\] )+\((\S+)\)</p>$)
        # One Line Forms
        action,method,form = $2,'get',''
        line.scan(/(\w+):\[(\*)?(\w+)\] /).each do |field, pwd, name|
          type = (pwd)? 'password' : 'text'
          method = 'post' if pwd
          form << %Q{  #{field}:<input type="#{type}" name="#{name}">\n}
        end
        line = %Q(<form action="#{action}" method="#{method}">\n) +
          form + %Q(  <input type="submit">\n</form>)
      when %r(^<p><img (src="[^"]*" alt=" [^"]* ") /></p>$)
        line = %Q(<img style="display: block; margin-left: auto; margin-right: auto;" #{$1} />)
      when %r(^<p><img (src="[^"]*" alt=" [^"]*") />$)
        line = %Q(<p><img style="float: left;" #{$1} />)
      when %r(^<p><img (src="[^"]*" alt="[^"]* ") />$)
        line = %Q(<p><img style="float: right;" #{$1} />)
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
    Base.page(key){ Base.post_process markdown Base.pre_process text}
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
