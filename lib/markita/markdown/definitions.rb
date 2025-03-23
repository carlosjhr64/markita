# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Definitions
      RGX = /^[+] (.+)$/
      def self.phrase(line)
        mdt = RGX.match(line)
        mdt[1] if mdt
      end

      def self.split(phrase)
        first, sep, second = phrase.split(/(:)/, 2).map(&:strip)
        sep ? [first, second] : [nil, first]
      end
    end

    @@parsers << :definitions

    # category: method
    # :reek:TooManyStatements
    def definitions
      return false unless (phrase = Definitions.phrase(@line))

      @html << "<dl#{@attributes.shift}>\n"
      while phrase
        term, definition = Definitions.split(phrase)
        @html << "<dt>#{inline term}</dt>\n" if term
        @html << "<dd>#{inline definition}</dd>\n" if definition
        phrase = Definitions.phrase(line_gets)
      end
      @html << "</dl>\n"
      true
    end
  end
end
