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

  def Base.page(key)
    begin
      Base.header(key) + yield + Base.footer
    rescue
      $stderr.puts $!
      raise Sinatra::NotFound
    end
  end

  def Base.post_process(text)
    val,string,_ = {},'',nil
    text.each_line do |line|
      line.force_encoding('utf-8').chomp!
      case line
      when val[:reset]
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
        line = %Q(<form action="#{action}" method="#{method}">\n)+form+%Q(  <input type="submit">\n</form>)
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

  before do
    unless VALID_ID.nil? or ALLOWED_IPS&.include?(request.ip)
      if id = params[:id]
        session[:id] = Digest::SHA256.hexdigest id
      end
      if session[:id] == VALID_ID
        redirect '/' if request.path_info == '/login.html'
      else
        redirect '/login.html' unless request.path_info == '/login.html'
      end
    end
    puts "#{request.ip} #{request.path_info}"
  end

  get '/' do
    Base.page(:index){ markdown :index}
  end

  get '/favicon.ico' do
    headers 'Content-Type' => 'image/x-icon'
    FAVICON
  end

  get '/highlight.css' do
    headers 'Content-Type' => 'text/css'
    HIGHLIGHT
  end

  get %r{/(\w[\w\/\-]*\w)} do |key|
    Base.page(key){ Base.post_process markdown key.to_sym}
  end

  get %r{/img/(\w+).png} do |key|
    send_file File.join ROOT, 'img', key + '.png'
  end

  get '/login.html' do
<<LOGIN_FORM
<!DOCTYPE html>
<html>
<head><title>login</title></head>
<body>
<h1>MDServer</h1>
<form method="post">
Password:<input type="password" name="id">
</form>
</body>
</html>
LOGIN_FORM
  end

  post '/login.html' do
<<LOGIN_REJECTION
<!DOCTYPE html>
<html>
<head><title>login</title></head>
<body>
<h1>Bad Password</h1>
</body>
</html>
LOGIN_REJECTION
  end

  get '/restart.html' do
    version = VERSION
    if File.mtime(__FILE__) > START_TIME
      version = 'Restarting...'
      Thread.new do
        sleep(2)
        Kernel.exec(__FILE__)
      end
    end
<<RESTART
<!DOCTYPE html>
<html>
<head><title>restart</title></head>
<body>
<h1>#{version}</h1>
</body>
</html>
RESTART
  end

  not_found do
<<NOT_FOUND
<!DOCTYPE html>
<html>
<head><title>error</title></head>
<body>
<h1>Not Found (404)</h1>
</body>
</html>
NOT_FOUND
  end
end
end
