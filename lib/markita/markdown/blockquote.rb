# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Class to isolate from Markdown
    class Blockquote
      RGX = /^( {0,3})> (.*)$/

      def self.level_quote(mdt)
        [mdt[1].length, mdt[2]] if mdt.is_a?(MatchData)
      end
    end

    PARSERS << :blockquote

    # :reek:DuplicateMethodCall :reek:TooManyStatements
    # rubocop:disable Metrics/MethodLength
    def blockquote(mdt = Blockquote::RGX.match(@line))
      mdt or return false
      @html << "<blockquote#{@attributes.shift}>\n"
      level, quote = Blockquote.level_quote(mdt)
      current = level
      while current.eql?(level)
        @html << "#{inline(quote)}\n"
        @line = @file.gets
        mdt = Blockquote::RGX.match(@line)
        current, quote = Blockquote.level_quote(mdt)
        next unless current&.>(level)

        mdt = blockquote(mdt)
        current, quote = Blockquote.level_quote(mdt)
      end
      @html << "</blockquote>\n"
      mdt || true
    end
    # rubocop:enable Metrics/MethodLength
  end
end
