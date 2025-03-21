# frozen_string_literal: true

# Markita top level namespace
module Markita
  using Refinement
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    module Code
      RGX = /^[`]{3}\s*(\w+)?$/

      def self.code(file, lang, code = String.new)
        # Note that we can ignore the final shifted
        # line because it will be the closing fence.
        while (line = file.gets) && !RGX.match?(line)
          code << line
        end
        lang ? ROUGE.format(lang.new.lex(code)) : code
      end

      def self.klass_lang(line)
        if (mdt = RGX.match(line))
          lang = Rouge::Lexer.find(mdt[1])
          klass = lang ? ' class="highlight"' : ''
          [klass, lang]
        end
      end
    end

    PARSERS << :code

    # category: method
    # :reek:TooManyStatements
    def code
      return false unless (klass, lang = Code.klass_lang(@line))

      @html << "<pre#{klass}#{@attributes.shift}><code>\n"
      @html << Code.code(@file, lang)
      @html << "</code></pre>\n"
      @line = @file.gets
      true
    end
  end
end
