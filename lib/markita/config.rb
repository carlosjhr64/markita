module Markita
  OPTIONS ||= nil

  HEADER_LINKS = ''

  ROOT = File.expand_path OPTIONS&.root || '~/vimwiki'
  raise "Missing site root directory: "+ROOT  unless File.directory? ROOT
  APPDATA = File.join File.dirname(File.dirname __dir__), 'data'
  PATH = lambda do |basename|
    [ROOT, APPDATA].map{ File.join _1, basename}.detect{ File.exist? _1}
  end
  NOT_FOUND = File.read PATH['not_found.html']

  PAGE_KEY   = %r{/(\w[\w\/\-]*\w)}
  IMAGE_PATH = %r{/(\w[\w\/\-]*\w\.((png)|(gif)))}

  PREPROCESS = [
    lambda do |line, val|
      case line
      when val[:regx]
        # Template/Substitutions
        template = val[:template] || line
        $~.named_captures.each do |name, value|
          template = template.gsub("&#{name};", value)
          template = template.gsub("&#{name.upcase};", CGI.escape(value))
        end
        template
      else
        nil
      end
    end
  ]

  POSTPROCESS = [
    lambda do |line,_|
      case line
      when %r(^(\s*)<li>\[(x| )\] (.*)</li>$)
        # Task Lists
        spaces,x,item = $1,$2,$3
        li = (x=='x')?
          %q{<li style="list-style-type: '&#9745; '">} :
          %q{<li style="list-style-type: '&#9744; '">}
        spaces+li+item+"</li>"
      when %r(^<p>(\w+:\[\*?\w+\] )+\((\S+)\)</p>$)
        # One Line Forms
        action,method,form = $2,'get',[]
        line.scan(/(\w+):\[(\*)?(\w+)\] /).each do |field, pwd, name|
          type = (pwd)? 'password' : 'text'
          method = 'post' if pwd
          form << %Q{  #{field}:<input type="#{type}" name="#{name}">}
        end
        form.unshift %Q(<form action="#{action}" method="#{method}">)
        form.push %Q(  <input type="submit">) if form.length==1
        form.push %Q(</form>)
        form.join("\n")
      when %r(^<p><img (src="[^"]*" alt=" [^"]* ") /></p>$)
        %Q(<img style="display: block; margin-left: auto; margin-right: auto;" #{$1} />)
      when %r(^<p><img (src="[^"]*" alt=" [^"]*") />$)
        %Q(<p><img style="float: left;" #{$1} />)
      when %r(^<p><img (src="[^"]*" alt="[^"]* ") />$)
        %Q(<p><img style="float: right;" #{$1} />)
      else
        nil
      end
    end
  ]

  START_TIME = Time.now
end
