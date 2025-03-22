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
end
end
