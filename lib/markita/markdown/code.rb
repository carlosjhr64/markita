# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
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

    @@parsers << :code

    # category: method
    # :reek:TooManyStatements
    def code
      return false unless (klass, lang = Code.klass_lang(@line))

      @html << "<pre#{klass}#{@attributes.shift}><code>\n"
      @html << Code.code(@line_getter, lang)
      @html << "</code></pre>\n"
      line_gets
      true
    end
  end
end
