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
end
end
