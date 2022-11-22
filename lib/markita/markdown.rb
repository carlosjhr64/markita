module Markita
class Markdown
  ROUGE = Rouge::Formatters::HTML.new
  PARSERS = []

  def initialize(title)
    @title = title
    @line=@html=@file=@opt=nil
    @metadata = {}
  end

  def start
    @html << HTML.header(@title)
    @line = HTML.navigation
  end

  def finish
    if title = @metadata['Title']
      @html << %Q(<script> document.title = "#{title}" </script>\n)
    end
    @html << HTML.footer
    @line = nil
  end

  def default
    @html << @line
    @line = @file.gets
  end

  def init(fh)
    @file,@html,@opt = Preprocess.new(fh),'',{}
  end

  def parse(fh)
    init(fh)
    start
    while @line
      PARSERS.detect{method(_1).call} or default
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
  CODE  = lambda {|m| "<code>#{m[1].gsub('<','&lt;')}</code>"}

  Ax = /\[([^\[\]]+)\]\(([^()]+)\)/
  def anchor(m)
    href = ((_=m[2]).match?(/^\d+$/) and @metadata[_] or _)
    text = Markdown.tag(m[1], EMOJIx, EMOJI)
    %Q(<a href="#{href}">#{text}</a>)
  end

  URLx = %r((https?://[\w\.\-\/\&\+\?\%]+))
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
      string = ''
      while m
        pre_match = (block ? block.call(m.pre_match) : m.pre_match)
        string << pre_match + m2string[m]
        post_match = m.post_match
        m = regx.match(post_match)
      end
      string << (block ? block.call(post_match) : post_match)
      return string
    end
    return (block ? block.call(entry) : entry)
  end

  def inline(entry)
    string = Markdown.tag(entry, CODEx, CODE) do |entry|
      Markdown.tag(entry, Ax, method(:anchor)) do |entry|
        Markdown.tag(entry, URLx, URL) do |entry|
          entry = Markdown.tag(entry, EMOJIx, EMOJI)
          entry = Markdown.tag(entry, Bx, B)
          entry = Markdown.tag(entry, Ix, I)
          entry = Markdown.tag(entry, Sx, S)
          entry = Markdown.tag(entry, Ux, U)
          entry = Markdown.tag(entry, FOOTNOTEx, FOOTNOTE)
        end
      end
    end
    string.sub(/  $/,'<br>')
  end

  # Empty
  EMPTY = /^$/
  PARSERS << :empty
  def empty
    EMPTY.match?(@line) or return false
    @line = @file.gets
    true
  end

  # Ordered list
  ORDERED = /^( {0,3})\d+\. (\S.*)$/
  PARSERS << :ordered
  def ordered(md=nil)
    md ||= ORDERED.match(@line) or return false
    level = md[1].length
    @html << "<ol#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while md and level==md[1].length
      @html << "  <li>#{inline(md[2])}</li>\n"
      if md = (@line=@file.gets)&.match(ORDERED)
        if level < md[1].length
          ordered(md)
          md = @line&.match(ORDERED)
        end
      end
    end
    @html << "</ol>\n"
    true
  end

  # Paragraph
  PARAGRAPHS = /^[\[\(*`'"~_]?:?\w/
  PARSERS << :paragraphs
  def paragraphs
    md = PARAGRAPHS.match(@line) or return false
    @html << "<p#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while md
      @html << inline(@line)
      while (@line=@file.gets)&.start_with?('<')
        @html << @line # Exceptional HTML injection into the paragraph
      end
      md = @line&.match PARAGRAPHS
    end
    @html << "</p>\n"
    true
  end

  # Unordered list
  UNORDERED = /^( {0,3})[*] (\S.*)$/
  PARSERS << :unordered
  def unordered(md=nil)
    md ||= UNORDERED.match(@line) or return false
    level = md[1].length
    @html << "<ul#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while md and level==md[1].length
      @html << "  <li>#{inline(md[2])}</li>\n"
      if md = (@line=@file.gets)&.match(UNORDERED)
        if level < md[1].length
          unordered(md)
          md = @line&.match(UNORDERED)
        end
      end
    end
    @html << "</ul>\n"
    true
  end

  # Ballot box
  BALLOTS = /^- \[(x| )\] (.*)$/
  PARSERS << :ballots
  def ballots
    md = BALLOTS.match(@line) or return false
    @html << "<ul#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while md
      x,t = md[1],md[2]
      li = (x=='x')?
        %q{<li style="list-style-type: '&#9745; '">} :
        %q{<li style="list-style-type: '&#9744; '">}
      @html << "  #{li}#{inline(t)}</li>\n"
      md = (@line=@file.gets)&.match BALLOTS
    end
    @html << "</ul>\n"
    true
  end

  # Definition list
  DEFINITIONS = /^[+] (.*)$/
  PARSERS << :definitions
  def definitions
    md = DEFINITIONS.match(@line) or return false
    @html << "<dl#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while md
      case md[1]
      when /(.*): (.*)$/
        @html << "<dt>#{inline $1.strip}</dt>\n"
        @html << "<dd>#{inline $2.strip}</dd>\n"
      when /(.*):$/
        @html << "<dt>#{inline $1.strip}</dt>\n"
      else
        @html << "<dd>#{inline md[1].strip}</dd>\n"
      end
      md = (@line=@file.gets)&.match DEFINITIONS
    end
    @html << "</dl>\n"
    true
  end

  # Headers
  HEADERS = /^([#]{1,6}) (.*)$/
  PARSERS << :headers
  def headers
    md = HEADERS.match(@line) or return false
    i,header = md[1].length,md[2]
    id = header.gsub(/\([^\(\)]*\)/,'').scan(/\w+/).join('+')
    @html << %Q(<a id="#{id}">\n)
    @html << "  <h#{i}#{@opt[:attributes]}>#{inline(header)}</h#{i}>\n"
    @html << "</a>\n"
    @opt.delete(:attributes)
    @line = @file.gets
    true
  end

  # Block-quote
  BLOCKQS = /^( {0,3})> (.*)$/
  PARSERS << :blockqs
  def blockqs(md=nil)
    md ||= BLOCKQS.match(@line) or return false
    level = md[1].length
    @html << "<blockquote#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while md and level==md[1].length
      @html << inline(md[2])
      @html << "\n"
      if md = (@line=@file.gets)&.match(BLOCKQS)
        if level < md[1].length
          blockqs(md)
          md = @line&.match(BLOCKQS)
        end
      end
    end
    @html << "</blockquote>\n"
    true
  end

  # Code
  CODES = /^[`~]{3}\s*(\w+)?$/
  PARSERS << :codes
  def codes
    md = CODES.match(@line) or return false
    lang = Rouge::Lexer.find md[1]
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
  PARSERS << :preforms
  def preforms
    md = PREFORMS.match(@line) or return false
    @html << "<pre#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    while md
      @html << md[1]
      @html << "\n"
      md = (@line=@file.gets)&.match PREFORMS
    end
    @html << "</pre>\n"
    true
  end

  # Meta-data
  METADATAS = /^(\w+): (.*)$/
  def metadata
    md = METADATAS.match(@line) or return false
    while md
      @metadata[md[1]] = md[2]
      md = (@line=@file.gets)&.match METADATAS
    end
    true
  end

  # Horizontal rule or Meta-data
  HRS = /^---+$/
  PARSERS << :hrs
  def hrs
    HRS.match? @line or return false
    @line = @file.gets
    if metadata
      # Optional closing HRS
      @line = @file.gets if @line&.match? HRS
    else
      # Display HR
      @html << "<hr#{@opt[:attributes]}>\n"
      @opt.delete(:attributes)
    end
    true
  end

  # Table
  TABLES = /^\|.+\|$/
  PARSERS << :tables
  def tables
    TABLES.match? @line or return false
    @html << "<table#{@opt[:attributes]}>\n"
    @opt.delete(:attributes)
    @html << '<thead><tr><th>'
    @html << @line[1...-1].split('|').map{inline(_1.strip)}.join('</th><th>')
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
          @html << "<td#{align[i]}>#{inline(cell.strip)}</td>"
        end
      end
      @html << "</tr>\n"
    end
    @html << "</table>\n"
    true
  end

  # Splits
  SPLITS = /^:?\|:?$/
  PARSERS << :splits
  def splits
    SPLITS.match? @line or return false
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
  PARSERS << :images
  def images
    md = IMAGES.match(@line) or return false
    alt,src,href=md[1],*md[2].strip.split(/\s+/,2)
    style = ' '
    case alt
    when /^:.*:$/
      style = %Q( style="display: block; margin-left: auto; margin-right: auto;" )
    when /:$/
      style = %Q( style="float:left;" )
    when /^:/
      style = %Q( style="float:right;" )
    end
    if /(\d+)x(\d+)/.match alt
      style << %Q(width="#{$1}" height="#{$2}" )
    end
    @html << %Q(<a href="#{href}">\n) if href
    @html << %Q(<img src="#{src}"#{style}alt="#{alt.strip}"#{@opt[:attributes]}>\n)
    @html << %Q(</a>\n) if href
    @opt.delete(:attributes)
    @line = @file.gets
    true
  end

  # Forms
  FIELD = '(\w+:)?\[(\*)?(\w+)(=("[^"]+")(,"[^"]+")*)?\]'
  FIELDS = Regexp.new FIELD
  FORMS = Regexp.new "^!( #{FIELD})+"
  PARSERS << :forms
  def forms
    md = FORMS.match(@line) or return false
    fields,nl,submit = 0,false,nil
    action = (_=/\(([^\(\)]*)\)!?$/.match(@line))? %Q( action="#{_[1]}") : nil
    method = @line.match?(/!$/) ? ' method="post"' : nil
    @html << %Q(<form#{action}#{method}#{@opt[:attributes]}>\n)
    @opt.delete(:attributes)
    while md
      @html << "  <br>\n" if nl
      @line.scan(FIELDS).each do |field, pwd, name, value|
        field &&= field[0...-1]
        value &&= value[2...-1]
        if field
          type = (pwd)? 'password' : 'text'
          if value
            if (values = value.split('","')).length > 1
              @html << %Q(#{field}:<select name="#{name}">\n)
              values.each do |value|
                fields += 1
                @html << %Q(  <option value="#{value}">#{value}</option>\n)
              end
              @html << "</select>\n"
            else
              fields += 1
              @html << %Q{  #{field}:<input type="#{type}" name="#{name}" value="#{value}">\n}
            end
          else
            fields += 1
            @html << %Q{  #{field}:<input type="#{type}" name="#{name}">\n}
          end
        elsif name=='submit'
          submit = value
        else
          @html << %Q{  <input type="hidden" name="#{name}" value="#{value}">\n}
        end
      end
      md=(@line=@file.gets)&.match(FORMS) and nl=true
    end
    if submit or not fields==1
      submit ||= 'Submit'
      @html << "  <br>\n" if nl
      @html << %Q(  <input type="submit" value="#{submit}">\n)
    end
    @html << %Q(</form>\n)
    true
  end

  # Embed text
  EMBED_TEXTS = /^!> (#{PAGE_KEY}\.\w+)$/
  PARSERS << :embed_texts
  def embed_texts
    md = EMBED_TEXTS.match(@line) or return false
    if File.exist?(filename=File.join(ROOT, md[1]))
      extension,lang = filename.split('.').last,nil
      unless extension=='html'
        lang = Rouge::Lexer.find(extension) unless extension=='txt'
        klass = lang ? ' class="highlight"' : nil
        @html << "<pre#{klass}#{@opt[:attributes]}>"
        @opt.delete(:attributes)
        @html << '<code>' if lang
        @html << "\n"
      end
      code = File.read(filename)
      @html << (lang ? ROUGE.format(lang.new.lex(code)) : code)
      unless extension=='html'
        @html << '</code>' if lang
        @html << '</pre>'
        @html << "\n"
      end
    else
      @html << @line
    end
    @line = @file.gets
    true
  end

  # Footnotes
  FOOTNOTES = /^\[\^\d+\]:/
  PARSERS << :footnotes
  def footnotes
    md = FOOTNOTES.match(@line) or return false
    @html << "<small>\n"
    while md
      @html << inline(@line.chomp)+"<br>\n"
      md = (@line=@file.gets)&.match FOOTNOTES
    end
    @html << "</small>\n"
    true
  end

  # Attributes
  ATTRIBUTES = /^\{:( .*)\}/
  PARSERS << :attributes
  def attributes
    md = ATTRIBUTES.match(@line) or return false
    @opt[:attributes] = md[1]
    @line = md.post_match
    true
  end
end
end
