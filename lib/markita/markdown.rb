module Markita
class Markdown
  ROUGE = Rouge::Formatters::HTML.new
  PARSERS = Hash.new

  def initialize(title)
    @title = title
    @line=@html=@file=@opt=@md=nil
  end

  def default
    @html << @line
    @line = @file.gets
  end

  def start
    @line,@html,@opt = HTML.header(@title),'',{}
  end

  def finish
    @html << HTML.footer
  end

  def parse(fh)
    @file = Preprocess.new(fh)
    start
    while @line
      PARSERS.detect{|r, m| @md = r.match(@line) and method(m).call} or default
    end
    finish
  end

  def markdown(string)
    parse StringIO.new string
    @html
  end

  def filepath(filepath)
    File.open(filepath, 'r'){|fh| parse fh}
    @html
  end

  Ux = /_([^_]+)_/
  U  = lambda {|m| "<u>#{m[1]}</u>"}

  Sx = /~([^~]+)~/
  S  = lambda {|m| "<s>#{m[1]}</s>"}

  Ix = /"([^"]+)"/
  I  = lambda {|m| "<i>#{m[1]}</i>"}

  Bx = /\*([^\*]+)\*/
  B  = lambda {|m| "<b>#{m[1]}</b>"}

  CODEx = /`([^`]+)`/
  CODE  = lambda {|m| "<code>#{m[1]}</code>"}

  Ax = /\[([^\[\]]+)\]\(([^()]+)\)/
  A  = lambda {|m| %Q(<a href="#{m[2]}">#{m[1]}</a>)}

  URLx = %r(\[(https?://[\w\.\-\/\&\+\?\%]+)\])
  URL  = lambda {|m| %Q(<a href="#{m[1]}">#{m[1]}</a>)}

  EMOJIx = /:(\w+):/
  EMOJI  = lambda {|m| (_=EMOJIS[m[1]])? "&\#x#{_};" : m[0]}

  FOOTNOTEx = /\[\^(\d+)\](:)?/
  FOOTNOTE  = lambda do |m|
    if m[2]
      %Q(<a id="fn:#{m[1]}" href="\#fnref:#{m[1]}">#{m[1]}:</a>)
    else
      %Q(<a id="fnref:#{m[1]}" href="\#fn:#{m[1]}"><sup>#{m[1]}</sup></a>)
    end
  end

  def Markdown.tag(entry, regx, m2string, &block)
    if m = regx.match(entry)
      pre_match = (block ? block.call(m.pre_match) : m.pre_match)
      string = pre_match + m2string[m]
      post_match = m.post_match
      while m = regx.match(post_match)
        pre_match = (block ? block.call(m.pre_match) : m.pre_match)
        string << pre_match + m2string[m]
        post_match = m.post_match
      end
      string << (block ? block.call(post_match) : post_match)
      return string
    end
    return (block ? block.call(entry) : entry)
  end

  INLINE = lambda do |entry|
    string = Markdown.tag(entry, CODEx, CODE) do |entry|
      Markdown.tag(entry, Ax, A) do |entry|
        Markdown.tag(entry, URLx, URL) do |entry|
          string = Markdown.tag(entry, Bx, B)
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

  # Empty
  EMPTY = /^$/
  PARSERS[EMPTY] = :empty
  def empty
    @line = @file.gets
    true
  end

  # Ordered list
  ORDERED = /^\d+. (.*)$/
  PARSERS[ORDERED] = :ordered
  def ordered
    @html << "<ol#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while @md
      @html << "  <li>#{INLINE[@md[1]]}</li>\n"
      @md = (@line=@file.gets)&.match ORDERED
    end
    @html << "</ol>\n"
    true
  end

  # Paragraph
  PARAGRAPHS = /^[\[`*"~_]?\w/
  PARSERS[PARAGRAPHS] = :paragraphs
  def paragraphs
    @html << "<p#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while @md
      @html << INLINE[@line]
      @md = (@line=@file.gets)&.match PARAGRAPHS
    end
    @html << "</p>\n"
    true
  end

  # Unordered list
  UNORDERED = /^[*] (.*)$/
  PARSERS[UNORDERED] = :unordered
  def unordered
    @html << "<ul#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while @md
      @html << "  <li>#{INLINE[@md[1]]}</li>\n"
      @md = (@line=@file.gets)&.match UNORDERED
    end
    @html << "</ul>\n"
    true
  end

  # Ballot box
  BALLOTS = /^- \[(x| )\] (.*)$/
  PARSERS[BALLOTS] = :ballots
  def ballots
    @html << "<ul#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while @md
      x,t = @md[1],@md[2]
      li = (x=='x')?
        %q{<li style="list-style-type: '&#9745; '">} :
        %q{<li style="list-style-type: '&#9744; '">}
      @html << "  #{li}#{INLINE[t]}</li>\n"
      @md = (@line=@file.gets)&.match BALLOTS
    end
    @html << "</ul>\n"
    true
  end

  # Definition list
  DEFINITIONS = /^: (.*)$/
  PARSERS[DEFINITIONS] = :definitions
  def definitions
    @html << "<dl#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while @md
      item = @md[1]
      @html << ((item[-1]==':')? "<dt>#{INLINE[item[0..-2]]}</dt>\n" :
              "<dd>#{INLINE[item]}</dd>\n")
      @md = (@line=@file.gets)&.match DEFINITIONS
    end
    @html << "</dl>\n"
    true
  end

  # Headers
  HEADERS = /^([#]{1,6}) (.*)$/
  PARSERS[HEADERS] = :headers
  def headers
    i,header = @md[1].length,@md[2]
    id = header.strip.gsub(/\s+/,'+')
    @html << %Q(<a id="#{id}">\n)
    @html << "  <h#{i}#{@opt[:attributes]}>#{INLINE[header]}</h#{i}>\n"
    @html << "</a>\n"
    @opt.delete(:attributes)
    @line = @file.gets
    true
  end

  # Block-quote
  BLOCKQS = /^> (.*)$/
  PARSERS[BLOCKQS] = :blockqs
  def blockqs
    @html << "<blockquote#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while @md
      @html << INLINE[@md[1]]
      @html << "\n"
      @md = (@line=@file.gets)&.match BLOCKQS
    end
    @html << "</blockquote>\n"
    true
  end


  # Code
  CODES = /^[`~]{3}\s*(\w+)?$/
  PARSERS[CODES] = :codes
  def codes
    lang = Rouge::Lexer.find @md[1]
    klass = lang ? ' class="highlight"' : nil
    @html << "<pre#{klass}#{@opt[:attributes]}><code>\n"
    @opt.delete(:attributes)
    code = ''
    while @line=@file.gets and not CODES.match(@line)
      code << @line
    end
    @html << (lang ? ROUGE.format(lang.new.lex(code)) : code)
    @html << "</code></pre>\n"
    @line = @file.gets if @line # then it's code close and thus need next @line.
    true
  end

  # Preform
  PREFORMS = /^ {4}(.*)$/
  PARSERS[PREFORMS] = :preforms
  def preforms
    @html << "<pre#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while @md
      @html << @md[1]
      @html << "\n"
      @md = (@line=@file.gets)&.match PREFORMS
    end
    @html << "</pre>\n"
    true
  end

  # Horizontal rule
  HRS = /^---+$/
  PARSERS[HRS] = :hrs
  def hrs
    @html << "<hr#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    @line = @file.gets
    true
  end

  # Table
  TABLES = /^\|.+\|$/
  PARSERS[TABLES] = :tables
  def tables
    @html << "<table#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    @html << '<thead><tr><th>'
    @html << @line[1...-1].split('|').map{INLINE[_1.strip]}.join('</th><th>')
    @html << "</th></tr></thead>\n"
    align = []
    while (@line=@file.gets)&.match TABLES
      @html << '<tr>'
      @line[1...-1].split('|').each_with_index do |cell, i|
        case cell
        when /^\s*:-+:\s*$/
          align[i] = ' align="center"'
          @html << '<td><hr></td>'
        when /^\s*-+:\s*$/
          align[i] = ' align="right"'
          @html << '<td><hr></td>'
        when /^\s*:-+\s*$/
          align[i] = ' align="left"'
          @html << '<td><hr></td>'
        else
          @html << "<td#{align[i]}>#{INLINE[cell.strip]}</td>"
        end
      end
      @html << "</tr>\n"
    end
    @html << "</table>\n"
    true
  end

  # Splits
  SPLITS = /^:?\|:?$/
  PARSERS[SPLITS] = :splits
  def splits
    case @line.chomp
    when '|:'
      @html << %Q(<table><tr><td#{@opt[:attributes]}>\n)
    when '|'
      @html << %Q(</td><td#{@opt[:attributes]}>\n)
    when ':|:'
      @html << %Q(</td></tr><tr><td#{@opt[:attributes]}>\n)
    when ':|'
      @html << %Q(</td></tr></table>\n)
    end
    @opt.delete(:attributes)
    @line = @file.gets
    true
  end

  # Image
  IMAGES = /^!\[([^\[\]]+)\]\(([^\(\)]+)\)$/
  PARSERS[IMAGES] = :images
  def images
    alt,src=@md[1],@md[2]
    style = ' '
    case alt
    when /^ .* $/
      style = %Q( style="display: block; margin-left: auto; margin-right: auto;" )
    when / $/
      style = %Q( style="float:left;" )
    when /^ /
      style = %Q( style="float:right;" )
    end
    @html << %Q(<img src="#{src}"#{style}alt="#{alt.strip}"#{@opt[:attributes]}>\n)
    @opt.delete(:attributes)
    @line = @file.gets
    true
  end

  # Forms
  FORMS = /^!( (\w+:)?\[\*?\w+(="[^"]*")?\])+/
  PARSERS[FORMS] = :forms
  def forms
    form = []
    n,fields,submit,method = 0,0,nil,nil
    action = (_=/\(([^\(\)]*)\)$/.match(@line))? _[1] : nil
    while @md
      n += 1
      form << '  <br>' if n > 1
      @line.scan(/(\w+:)?\[(\*)?(\w+)(="[^"]*")?\]/).each do |field, pwd, name, value|
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
      @md = (@line=@file.gets)&.match FORMS
    end
    if submit or not fields==1
      submit ||= 'Submit'
      form << '  <br>' if n > 1
      form << %Q(  <input type="submit" value="#{submit}">)
    end
    form.unshift %Q(<form action="#{action}"#{method}#{@opt[:attributes]}>)
    form << %Q(</form>)
    @html << form.join("\n")
    @html << "\n"
    @opt.delete(:attributes)
    true
  end

  # Embed text
  EMBED_TEXTS = /^!> (#{PAGE_KEY}\.txt)$/
  PARSERS[EMBED_TEXTS] = :embed_texts
  def embed_texts
    if File.exist?(filename=File.join(ROOT, @md[1]))
      @html << "<pre>\n"
      @html << File.read(filename)
      @html << "</pre>\n"
    else
      @html << @line
    end
    @line = @file.gets
    true
  end

  # Footnotes
  FOOTNOTES = /^\[\^\d+\]:/
  PARSERS[FOOTNOTES] = :footnotes
  def footnotes
    @html << "<small>\n"
    while @md
      @html << INLINE[@line.chomp]+"<br>\n"
      @md = (@line=@file.gets)&.match FOOTNOTES
    end
    @html << "</small>\n"
    true
  end

  # Attributes
  ATTRIBUTES = /^\{:( .*)\}/
  PARSERS[ATTRIBUTES] = :attributes
  def attributes
    @opt[:attributes] = @md[1]
    @line = @md.post_match
    true
  end
end
end
