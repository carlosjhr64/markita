# frozen_string_literal: true

# Markita top level namespace
module Markita
  # The markdown parser.
  # :reek:ClassVariable :reek:TooManyInstanceVariables
  # rubocop:disable Style/ClassVars
  class Markdown
    ROUGE = Rouge::Formatters::HTML.new

    @@parsers = []

    def initialize(title)
      @title = title
      @line = @html = @line_getter = nil
      @metadata = {}
      @attributes = []
    end

    def finish
      if (title = @metadata['Title'])
        @html << %(<script> document.title = "#{title}" </script>\n)
      end
      @html << HTML.footer
      @line = nil
    end

    # init(fh: String || File) -> void
    def init(line_getter)
      @line_getter = Preprocess.new(line_getter)
      @html = String.new
    end

    def start
      @html << HTML.header(@title)
      @line = HTML.navigation
    end

    def parse(line_getter)
      init(line_getter)
      start
      parsers_detect or default while @line
      finish
    end

    def filepath(filepath)
      File.open(filepath, 'r') { parse it }
      @html
    end

    def markdown(string)
      parse StringIO.new string
      @html
    end

    def parsers_detect = @@parsers.detect { method(it).call }

    # Defaults to paragraph
    # :reek:DuplicateMethodCall :reek:TooManyStatements
    def default
      # Let html take the original @html String and set @html to String.new('')
      html = @html
      @html = String.new
      html << "<p#{@attributes.shift}>\n"
      html << inline(@line)
      html << inline(@line) while line_gets && !parsers_detect
      html << "</p>\n#{@html}"
      @html = html # Give back the original String to @html
    end

    def line_gets = @line = @line_getter.gets
  end
  # rubocop:enable Style/ClassVars
end
