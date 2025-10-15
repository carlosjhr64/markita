# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Blockquote
      RGX = /^( {0,3})> (.*)$/

      def self.level_quote(line)
        mdt = RGX.match(line)
        [mdt[1].length, mdt[2]] if mdt
      end
    end

    @@parsers << :blockquote

    # category: method
    # :reek:DuplicateMethodCall :reek:TooManyStatements
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Lint/UselessAssignment
    def blockquote
      return false unless (level, quote = Blockquote.level_quote(@line))

      @html << "<blockquote#{@attributes.shift}>\n"
      current = level
      while current.eql?(level)
        @html << "#{inline(quote)}\n"
        # `quote` is being used... Code is just gnarly.
        current, quote = Blockquote.level_quote(line_gets)
        next unless current&.>(level)

        blockquote
        level, quote = Blockquote.level_quote(@line)
      end
      @html << "</blockquote>\n"
      true
    end
    # rubocop:enable Lint/UselessAssignment
    # rubocop:enable Metrics/MethodLength
  end
end
