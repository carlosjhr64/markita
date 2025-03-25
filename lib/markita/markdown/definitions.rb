# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Definitions
      RGX = /^[+] (\S.+)$/
      def self.phrase(line)
        mdt = RGX.match(line)
        mdt[1] if mdt
      end

      def self.split(phrase)
        return [phrase.chop, nil] if /:$/.match?(phrase)
        return [nil, phrase] unless (mdt = /^(.*): +(\S.*)$/.match(phrase))

        [mdt[1], mdt[2]]
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
