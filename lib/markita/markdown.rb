module Markita
module Markdown
  Ux = /_([^_]+)_/
  U  = lambda {|md| "<u>#{md[1]}</u>"}

  Sx = /~([^~]+)~/
  S  = lambda {|md| "<s>#{md[1]}</s>"}

  Ix = /"([^"]+)"/
  I  = lambda {|md| "<i>#{md[1]}</i>"}

  Bx = /\*([^\*]+)\*/
  B  = lambda {|md| "<b>#{md[1]}</b>"}

  CODEx = /`([^`]+)`/
  CODE  = lambda {|md| "<code>#{md[1]}</code>"}

  Ax = /\[([^\[\]]+)\]\(([^()]+)\)/
  A  = lambda {|md| %Q(<a href="#{md[2]}">#{md[1]}</a>)}

  URLx = %r(\[(https?://[\w\.\-\/\&\+\?\%]+)\])
  URL  = lambda {|md| %Q(<a href="#{md[1]}">#{md[1]}</a>)}

  EMOJIx = /:(\w+):/
  EMOJI  = lambda {|md| (_=EMOJIS[md[1]])? "&\#x#{_};" : md[0]}

  FOOTNOTEx = /\[\^(\d+)\](:)?/
  FOOTNOTE  = lambda do |md|
    if md[2]
      %Q(<a id="fn:#{md[1]}" href="\#fnref:#{md[1]}">#{md[1]}:</a>)
    else
      %Q(<a id="fnref:#{md[1]}" href="\#fn:#{md[1]}"><sup>#{md[1]}</sup></a>)
    end
  end

  def Markdown.tag(line, regx, md2string, &block)
    if md = regx.match(line)
      pre_match = (block ? block.call(md.pre_match) : md.pre_match)
      string = pre_match + md2string[md]
      post_match = md.post_match
      while md = regx.match(post_match)
        pre_match = (block ? block.call(md.pre_match) : md.pre_match)
        string << pre_match + md2string[md]
        post_match = md.post_match
      end
      string << (block ? block.call(post_match) : post_match)
      return string
    end
    return (block ? block.call(line) : line)
  end

  INLINE = lambda do |line|
    string = Markdown.tag(line, CODEx, CODE) do |line|
      Markdown.tag(line, Ax, A) do |line|
        Markdown.tag(line, URLx, URL) do |line|
          string = Markdown.tag(line, Bx, B)
          string = Markdown.tag(string, Ix, I)
          string = Markdown.tag(string, Sx, S)
          string = Markdown.tag(string, Ux, U)
          string = Markdown.tag(string, FOOTNOTEx, FOOTNOTE)
          Markdown.tag(string, EMOJIx, EMOJI)
        end
      end
    end
    string.sub(/  $/,'<br>')
  end

  PARSER = Hash.new

  # Empty
  PARSER[/^$/] = lambda do |_, _, file, _, _|
    file.gets
  end

  # Ordered list
  ORDERED = /^\d+. (.*)$/
  PARSER[ORDERED] = lambda do |line, html, file, opt, md|
    html << "<ol#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while md
      html << "  <li>#{INLINE[md[1]]}</li>\n"
      md = (line=file.gets)&.match ORDERED
    end
    html << "</ol>\n"
    line
  end

  # Paragraph
  PARAGRAPHS = /^[\[`*"~_]?\w/
  PARSER[PARAGRAPHS] = lambda do |line, html, file, opt, md|
    html << "<p#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while md
      html << INLINE[line]
      md = (line=file.gets)&.match PARAGRAPHS
    end
    html << "</p>\n"
    line
  end

  # Unordered list
  UNORDERED = /^[*] (.*)$/
  PARSER[UNORDERED] = lambda do |line, html, file, opt, md|
    html << "<ul#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while md
      html << "  <li>#{INLINE[md[1]]}</li>\n"
      md = (line=file.gets)&.match UNORDERED
    end
    html << "</ul>\n"
    line
  end

  # Ballot box
  BALLOTS = /^- \[(x| )\] (.*)$/
  PARSER[BALLOTS] = lambda do |line, html, file, opt, md|
    html << "<ul#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while md
      x,t = md[1],md[2]
      li = (x=='x')?
        %q{<li style="list-style-type: '&#9745; '">} :
        %q{<li style="list-style-type: '&#9744; '">}
      html << "  #{li}#{INLINE[t]}</li>\n"
      md = (line=file.gets)&.match BALLOTS
    end
    html << "</ul>\n"
    line
  end

  # Definition list
  DEFINITIONS = /^: (.*)$/
  PARSER[DEFINITIONS] = lambda do |line, html, file, opt, md|
    html << "<dl#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while md
      item = md[1]
      line = ((item[-1]==':')? "<dt>#{INLINE[item[0..-2]]}</dt>\n" :
              "<dd>#{INLINE[item]}</dd>\n")
      html << line
      md = (line=file.gets)&.match DEFINITIONS
    end
    html << "</dl>\n"
    line
  end

  # Headers
  HEADERS = /^([#]{1,6}) (.*)$/
  PARSER[HEADERS] = lambda do |line, html, file, opt, md|
    i,header = md[1].length,md[2]
    id = header.strip.gsub(/\s+/,'+')
    html << %Q(<a id="#{id}">\n)
    html << "  <h#{i}#{opt[:attributes]}>#{INLINE[header]}</h#{i}>\n"
    html << "</a>\n"
    opt.delete(:attributes)
    file.gets
  end

  # Block-quote
  BLOCKQS = /^> (.*)$/
  PARSER[BLOCKQS] = lambda do |line, html, file, opt, md|
    html << "<blockquote#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while md
      html << INLINE[md[1]]
      html << "\n"
      md = (line=file.gets)&.match BLOCKQS
    end
    html << "</blockquote>\n"
    line
  end

  HTML = Rouge::Formatters::HTML.new

  # Code
  CODES = /^[`~]{3}\s*(\w+)?$/
  PARSER[CODES] = lambda do |line, html, file, opt, md|
    lang = Rouge::Lexer.find md[1]
    klass = lang ? ' class="highlight"' : nil
    html << "<pre#{klass}#{opt[:attributes]}><code>\n"
    opt.delete(:attributes)
    code = ''
    while line=file.gets and not CODES.match(line)
      code << line
    end
    html << (lang ? HTML.format(lang.new.lex(code)) : code)
    html << "</code></pre>\n"
    # line is either nil or the code close
    line and file.gets
  end

  # Preform
  PREFORMS = /^ {4}(.*)$/
  PARSER[PREFORMS] = lambda do |line, html, file, opt, md|
    html << "<pre#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    while md
      html << md[1]
      html << "\n"
      md = (line=file.gets)&.match PREFORMS
    end
    html << "</pre>\n"
    line
  end

  # Horizontal rule
  HRS = /^---+$/
  PARSER[HRS] = lambda do |_, html, file, opt, _|
    html << "<hr#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    file.gets
  end

  # Table
  TABLES = /^\|.+\|$/
  PARSER[TABLES] = lambda do |line, html, file, opt, _|
    html << "<table#{opt[:attributes]}>\n"
    opt.delete(:attributes)
    html << '<thead><tr><th>'
    html << line[1...-1].split('|').map{INLINE[_1.strip]}.join('</th><th>')
    html << "</th></tr></thead>\n"
    align = []
    while (line=file.gets)&.match TABLES
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
  SPLITS = /^:?\|:?$/
  PARSER[SPLITS] = lambda do |line, html, file, opt, md|
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
  IMAGES = /^!\[([^\[\]]+)\]\(([^\(\)]+)\)$/
  PARSER[IMAGES] = lambda do |line, html, file, opt, md|
    if IMAGES.match line
      alt,src=$1,$2
      style = ' '
      case alt
      when /^ .* $/
        style = %Q( style="display: block; margin-left: auto; margin-right: auto;" )
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

  # Forms
  FORMS = /^!( (\w+:)?\[\*?\w+(="[^"]*")?\])+/
  PARSER[FORMS] = lambda do |line, html, file, opt, md|
    form = []
    lines,fields,submit,method = 0,0,nil,nil
    action = (_=/\(([^\(\)]*)\)$/.match(line))? _[1] : nil
    while line&.match? FORMS
      lines += 1
      form << '  <br>' if lines > 1
      line.scan(/(\w+:)?\[(\*)?(\w+)(="[^"]*")?\]/).each do |field, pwd, name, value|
        method ||= ' method="post"' if pwd
        field &&= field[0...-1]
        value &&= value[2...-1]
        if field
          fields += 1
          type = (pwd)? 'password' : 'text'
          if value
            form << %Q{  #{field}:<input type="#{type}" name="#{name}" value="#{value}">}
          else
            form << %Q{  #{field}:<input type="#{type}" name="#{name}">}
          end
        elsif name=='submit'
          submit = value
        else
          form << %Q{  <input type="hidden" name="#{name}" value="#{value}">}
        end
      end
      line = file.gets
    end
    if submit or not fields==1
      submit ||= 'Submit'
      form << '  <br>' if lines > 1
      form << %Q(  <input type="submit" value="#{submit}">)
    end
    form.unshift %Q(<form action="#{action}"#{method}#{opt[:attributes]}>)
    form << %Q(</form>)
    html << form.join("\n")
    html << "\n"
    opt.delete(:attributes)
    line
  end

  # Embed text
  EMBED_TEXTS = /^!> (#{PAGE_KEY}\.txt)$/
  PARSER[EMBED_TEXTS] = lambda do |line, html, file, opt, md|
    if EMBED_TEXTS.match(line) and
        File.exist?(filename=File.join(ROOT, $1))
      html << "<pre>\n"
      html << File.read(filename)
      html << "</pre>\n"
    else
      html << line
    end
    file.gets
  end

  # Footnotes
  FOOTNOTES = /^\[\^\d+\]:/
  PARSER[FOOTNOTES] = lambda do |line, html, file, opt, md|
    html << "<small>\n"
    while FOOTNOTES.match? line
      html << INLINE[line.chomp]+"<br>\n"
      line = file.gets
    end
    html << "</small>\n"
    line
  end

  # Attributes
  ATTRIBUTES = /^\{:( .*)\}/
  PARSER[ATTRIBUTES] = lambda do |line, html, file, opt, md|
    md = ATTRIBUTES.match line
    opt[:attributes] = md[1]
    md.post_match
  end
end
end
