# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Split
      RGX = /^:?\|:?$/

      # :reek:ControlParameter :reek:DuplicateMethodCall
      def self.table(code, attributes)
        case code
        when '|:'
          %(<table><tr><td#{attributes.shift}>\n)
        when '|'
          %(</td><td#{attributes.shift}>\n)
        when ':|:'
          %(</td></tr><tr><td#{attributes.shift}>\n)
        when ':|'
          %(</td></tr></table>\n)
        end
      end
    end

    @@parsers << :splits

    # category: method
    def splits
      return false unless Split::RGX.match? @line

      @html << Split.table(@line.chomp, @attributes)
      line_gets
      true
    end
  end
end
