module Markita
module Markdown
  TAG1 = lambda do |line, regx, stag, etag|
    if md = regx.match(line)
      line = md.pre_match + stag + md[1] + etag
      post_match = md.post_match
      while md = regx.match(post_match)
        line << md.pre_match + stag + md[1] + etag
        post_match = md.post_match
      end
      line << post_match
      line
    end
    line
  end

  LX = /\[([^\[\]]+)\]\(([^()]+)\)/
  INLINE = lambda do |line|
    if line == (line=TAG1[line, /`([^`]+)`/, '<code>', '</code>'])
      if not /[<>]/.match? line
        line = TAG1[line, /\*([^*]+)\*/, '<b>', '</b>']
        line = TAG1[line, /\"([^"]+)\"/, '<i>', '</i>']
      end
    end
    if md = LX.match(line)
      line = md.pre_match + %Q(<a href="#{md[2]}">#{md[1]}</a>)
      post_match = md.post_match
      while md = LX.match(post_match)
        line << md.pre_match + %Q(<a href="#{md[2]}">#{md[1]}</a>)
        post_match = md.post_match
      end
      line << post_match
    end
    line.sub(/  $/,'<br>')
  end

  PARSER = Hash.new

  # Empty
  PARSER[/^$/] = lambda do |line, html, file, opt|
    file.gets
  end

  # Ordered list
  PARSER[/^\d+\. /] = lambda do |line, html, file, opt|
    html << "<ol#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while line&.match /^\d+. (.*)$/
      html << "  <li>#{INLINE[$1]}</li>\n"
      line = file.gets
    end
    html << "</ol>\n"
    line
  end

  # Paragraph
  PARAGRAPH = /^[\[\*\"]?\w/
  PARSER[PARAGRAPH] = lambda do |line, html, file, opt|
    html << "<p#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while line&.match PARAGRAPH
      html << INLINE[line]
      line = file.gets
    end
    html << "<p>\n"
    line
  end

  # Unordered list
  PARSER[/^\* /] = lambda do |line, html, file, opt|
    html << "<ul#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while line&.match /^[*] (.*)$/
      html << "  <li>#{INLINE[$1]}</li>\n"
      line = file.gets
    end
    html << "</ul>\n"
    line
  end

  # Ballot box
  PARSER[/^- \[x| \] /] = lambda do |line, html, file, opt|
    html << "<ul#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while line&.match /^- \[(x| )\] (.*)$/
      x,t = $1,$2
      li = (x=='x')?
        %q{<li style="list-style-type: '&#9745; '">} :
        %q{<li style="list-style-type: '&#9744; '">}
      html << "  #{li}#{INLINE[t]}</li>\n"
      line = file.gets
    end
    html << "</ul>\n"
    line
  end

  # Definition list
  PARSER[/^: .+:$/] = lambda do |line, html, file, opt|
    html << "<dl#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while line&.match /^: (.*)$/
      line = (($1[-1]==':')? "<dt>#{INLINE[$1[0..-2]]}</dt>\n" :
              "<dd>#{INLINE[$1]}</dd>\n")
      html << line
      line = file.gets
    end
    html << "</dl>\n"
    line
  end

  # Headers
  PARSER[/^[#]{1,6} /] = lambda do |line, html, file, opt|
    if line.match /^([#]{1,6}) (.*)$/
      i,header = $1.length,$2
      html << "<h#{i}#{opt[:attributes]}>#{INLINE[header]}</h#{i}>\n"
    end
    opt.delete(:attributes)
    file.gets
  end

  # Block-quote
  PARSER[/^> /] = lambda do |line, html, file, opt|
    html << "<blockquote#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while line&.match /^> (.*)$/
      html << INLINE[$1]
      html << "\n"
      line = file.gets
    end
    html << "</blockquote>\n"
    line
  end

  HTML = Rouge::Formatters::HTML.new

  # Code
  PARSER[/^[`~]{3}\s*\w*$/] = lambda do |line, html, file, opt|
    lang = (/(\w+)$/.match line)? Rouge::Lexer.find($1) : nil
    klass = lang ? ' class="highlight"' : nil
    html << "<pre#{klass}#{opt[:attributes]}><code>\n"
    opt.delete(:attributes)
    code = ''
    while line = file.gets and not line.match /^[`~]{3}$/
      code << line
    end
    html << (lang ? HTML.format(lang.new.lex(code)) : code)
    html << "</code></pre>\n"
    # line is either nil or the code close
    line and file.gets
  end

  # Preform
  PARSER[/^ {4}/] = lambda do |line, html, file, opt|
    html << "<pre#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while line&.match /^ {4}(.*)$/
      html << $1
      html << "\n"
      line = file.gets
    end
    html << "</pre>\n"
    line
  end

  # Horizontal rule
  PARSER[/^---+$/] = lambda do |line, html, file, opt|
    html << "<hr#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    file.gets
  end

  # Table
  PARSER[/^\|.+\|$/] = lambda do |line, html, file, opt|
    html << "<table#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    html << '<thead><tr><th>'
    html << line[1...-1].split('|').map{INLINE[_1.strip]}.join('</th><th>')
    html << "</th></tr></thead>\n"
    align = []
    while line = file.gets and line.match /^\|.+\|$/
      html << '<tr>'
      line[1...-1].split('|').each_with_index do |cell, i|
        case cell
        when /^\s*:-+:\s*$/
          align[i] = ' align="center"'
          html << '<td><hr></td>'
        when /^\s*-+:\s*$/
          align[i] = ' align="right"'
          html << '<td><hr></td>'
        when /^\s*:-+\s*$/
          align[i] = ' align="left"'
          html << '<td><hr></td>'
        else
          html << "<td#{align[i]}>#{INLINE[cell.strip]}</td>"
        end
      end
      html << "</tr>\n"
    end
    html << "</table>\n"
    line
  end

  # Splits
  PARSER[/^:?\|:?$/] = lambda do |line, html, file, opt|
    case line.chomp
    when '|:'
      html << %Q(<table><tr><td#{opt[:attributes]}>\n)
    when '|'
      html << %Q(</td><td#{opt[:attributes]}>\n)
    when ':|:'
      html << %Q(</td></tr><tr><td#{opt[:attributes]}>\n)
    when ':|'
      html << %Q(</td></tr></table>\n)
    end
    opt.delete(:attributes)
    file.gets
  end

  # Image
  PARSER[/^!\[[^\[\]]+\]\([^\(\)]+\)$/] = lambda do |line, html, file, opt|
    if line.match /^!\[([^\[\]]+)\]\(([^\(\)]+)\)$/
      alt,src=$1,$2
      style = ' '
      case alt
      when /^ .* $/
        style = %Q(style="display: block; margin-left: auto; margin-right: auto;")
      when / $/
        style = %Q( style="float:left;" )
      when /^ /
        style = %Q( style="float:right;" )
      end
      html << %Q(<img src="#{src}"#{style}alt="#{alt.strip}"#{opt[:attributes]}>\n)
    end
    opt.delete(:attributes)
    file.gets
  end

  # Single line form
  PARSER[/^! (\w+:\[\*?\w+\] )+\([^()]+\)$/] = lambda do |line, html, file, opt|
    # One Line Forms
    if /\((.*)\)$/.match line
      action,method,form = $1,nil,[]
      line.scan(/(\w+):\[(\*)?(\w+)\] /).each do |field, pwd, name|
         type = (pwd)? 'password' : 'text'
         method ||= ' method="post"' if pwd
         form << %Q{  #{field}:<input type="#{type}" name="#{name}">}
       end
      form.push %Q(  <input type="submit">) if form.length>1
      form.unshift %Q(<form action="#{action}"#{method}#{opt[:attributes]}>)
      form.push %Q(</form>)
      html << form.join("\n")
      html << "\n"
    end
    opt.delete(:attributes)
    file.gets
  end

  # Embed text
  PARSER[/^!> #{PAGE_KEY}\.txt$/] = lambda do |line, html, file, opt|
    if /^!> (#{PAGE_KEY}\.txt)$/.match(line) and
        File.exist?(filename=File.join(ROOT, $1))
      html << "<pre>\n"
      html << File.read(filename)
      html << "</pre>\n"
    else
      html << line
    end
    file.gets
  end

  # Attributes
  PARSER[/^\{: .+\}$/] = lambda do |line, html, file, opt|
    if line.match /^\{:( .*)\}$/
      opt[:attributes] = $1
    end
    file.gets
  end
end
end
