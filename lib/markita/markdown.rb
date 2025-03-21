module Markita
class Markdown
  ROUGE = Rouge::Formatters::HTML.new
  PARSERS = []

  def initialize(title)
    @title = title
    @line=@html=@file=nil
    @metadata,@attributes = {},[]
  end

  def start
    @html << HTML.header(@title)
    @line = HTML.navigation
  end

  def finish
    if (title=@metadata['Title'])
      @html << %(<script> document.title = "#{title}" </script>\n)
    end
    @html << HTML.footer
    @line = nil
  end

  # init(fh: String || File) -> void
  def init(fh)
    @file,@html = Preprocess.new(fh),''
  end

  def parse(fh)
    init(fh)
    start
    PARSERS.detect{method(_1).call} or default while @line
    finish
  end

  def default
    # Defaults to paragraph
    # Let html take the original @html object and set @html to ''
    html,@html = @html,''
    html << "<p#{@attributes.shift}>\n"
    loop do
      html << inline(@line)
      break if (@line=@file.gets).nil? || PARSERS.detect{method(_1).call}
    end
    html << "</p>\n"
    html << @html
    # Give back the original object to @html
    @html = html
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
  U  = ->(m){"<u>#{m[1]}</u>"}

  Sx = /~([^~]+)~/
  S  = ->(m){"<s>#{m[1]}</s>"}

  Ix = /"([^"]+)"/
  I  = ->(m){"<i>#{m[1]}</i>"}

  Bx = /\*([^*]+)\*/
  B  = ->(m){"<b>#{m[1]}</b>"}

  CODEx = /`([^`]+)`/
  CODE  = ->(m){"<code>#{m[1].gsub('<','&lt;')}</code>"}

  Ax = /\[([^\[\]]+)\]\(([^()]+)\)/
  def anchor(m)
    href = ((_=m[2]).match?(/^\d+$/) and @metadata[_] or _)
    text = Markdown.tag(m[1], EMOJIx, EMOJI)
    %(<a href="#{href}">#{text}</a>)
  end

  URLx = %r{(https?://[\w./&+?%-]+)}
  URL  = ->(m){%(<a href="#{m[1]}">#{m[1]}</a>)}

  EMOJIx = /:(\w+):/
  EMOJI  = ->(m){(_=EMOJIS[m[1]])? "&#x#{_};" : m[0]}

  FOOTNOTEx = /\[\^(\d+)\](:)?/
  FOOTNOTE  = lambda do |m|
    if m[2]
      %(<a id="fn:#{m[1]}" href="#fnref:#{m[1]}">#{m[1]}:</a>)
    else
      %(<a id="fnref:#{m[1]}" href="#fn:#{m[1]}"><sup>#{m[1]}</sup></a>)
    end
  end

  SUPERSCRIPTx = /\\\^\(([^()]+)\)/
  SUPERSCRIPT = ->(m){"<sup>#{m[1]}</sup>"}
  SUBSCRIPTx = /\\\(([^()]+)\)/
  SUBSCRIPT = ->(m){"<sub>#{m[1]}</sub>"}

  ENTITYx = /\\([<>*"~`_&;:\\])/
  ENTITY = ->(m){"&##{m[1].ord};"}

  def self.tag(entry, regx, m2string, &block)
    if (m=regx.match entry)
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
    block ? block.call(entry) : entry
  end

  def inline(entry)
    entry = Markdown.tag(entry, ENTITYx, ENTITY)
    string = Markdown.tag(entry, CODEx, CODE) do |entry|
      Markdown.tag(entry, Ax, method(:anchor)) do |entry|
        Markdown.tag(entry, URLx, URL) do |entry|
          entry = Markdown.tag(entry, EMOJIx, EMOJI)
          entry = Markdown.tag(entry, Bx, B)
          entry = Markdown.tag(entry, Ix, I)
          entry = Markdown.tag(entry, Sx, S)
          entry = Markdown.tag(entry, Ux, U)
          entry = Markdown.tag(entry, FOOTNOTEx, FOOTNOTE)
          entry = Markdown.tag(entry, SUPERSCRIPTx, SUPERSCRIPT)
          Markdown.tag(entry, SUBSCRIPTx, SUBSCRIPT)
        end
      end
    end
    string.sub(/ ?[ \\]$/,'<br>')
  end

  # Code
  CODES = /^[`]{3}\s*(\w+)?$/
  PARSERS << :codes
  def codes
    md = CODES.match(@line) or return false
    lang = Rouge::Lexer.find md[1]
    klass = lang ? ' class="highlight"' : nil
    @html << "<pre#{klass}#{@attributes.shift}><code>\n"
    code = ''
    code << @line while (@line=@file.gets) && !CODES.match?(@line)
    @html << (lang ? ROUGE.format(lang.new.lex(code)) : code)
    @html << "</code></pre>\n"
    @line = @file.gets if @line # then it's code close and thus need next @line.
    true
  end

  # Table
  TABLES = /^\|.+\|$/
  PARSERS << :tables
  def tables
    TABLES.match? @line or return false
    @html << "<table#{@attributes.shift}>\n"
    @html << "<thead#{@attributes.shift}><tr><th>"
    @html << @line[1...-1].split('|').map{inline(_1.strip)}.join('</th><th>')
    @html << "</th></tr></thead>\n"
    align = []
    while (@line=@file.gets)&.match? TABLES
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
      @html << %(<table><tr><td#{@attributes.shift}>\n)
    when '|'
      @html << %(</td><td#{@attributes.shift}>\n)
    when ':|:'
      @html << %(</td></tr><tr><td#{@attributes.shift}>\n)
    when ':|'
      @html << %(</td></tr></table>\n)
    end
    @line = @file.gets
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
        @html << "<pre#{klass}#{@attributes.shift}>"
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
  ATTRIBUTES = /^\{:( [^\{\}]+)\}/
  PARSERS << :attributes
  def attributes
    md = ATTRIBUTES.match(@line) or return false
    @attributes.push md[1]
    @line = md.post_match
    true
  end

  # Script
  SCRIPT = /^<script/
  PARSERS << :script
  def script
    SCRIPT.match(@line) or return false
    @html << @line
    while (@line=@file.gets)
      @html << @line
      break if %r{^</script>}.match?(@line)
    end
    @line = @file.gets if @line
    true
  end

  # Html
  HTML_MARKUP = /^ {0,3}<.*>$/
  PARSERS << :html_markup
  def html_markup
    HTML_MARKUP.match(@line) or return false
    @html << @line
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
    action = (_=/\(([^()]*)\)!?$/.match(@line))? %( action="#{_[1]}") : nil
    method = @line.match?(/!$/) ? ' method="post"' : nil
    @html << %(<form#{action}#{method}#{@attributes.shift}>\n)
    while md
      @html << "  <br>\n" if nl
      @line.scan(FIELDS).each do |field, pwd, name, value|
        field &&= field[0...-1]
        value &&= value[2...-1]
        if field
          type = pwd ? 'password' : 'text'
          if value
            if (values = value.split('","')).length > 1
              @html << %(#{field}:<select name="#{name}">\n)
              values.each do |value|
                fields += 1
                @html << %(  <option value="#{value}">#{value}</option>\n)
              end
              @html << "</select>\n"
            else
              fields += 1
              @html << %(  #{field}:<input type="#{type}" name="#{name}")
              @html << %( value="#{value}">\n)
            end
          else
            fields += 1
            @html << %(  #{field}:<input type="#{type}" name="#{name}">\n)
          end
        elsif name=='submit'
          submit = value
        else
          @html << %(  <input type="hidden" name="#{name}" value="#{value}">\n)
        end
      end
      md=(@line=@file.gets)&.match(FORMS) and nl=true
    end
    if submit || fields!=1
      submit ||= 'Submit'
      @html << "  <br>\n" if nl
      @html << %(  <input type="submit" value="#{submit}">\n)
    end
    @html << %(</form>\n)
    true
  end
end
end
