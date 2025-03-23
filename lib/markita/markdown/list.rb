# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module List
      # rubocop:disable Lint/MixedRegexpCaptureTypes
      RGX = /^(?<spaces>\s{0,3})
              (?<bullet>[*]|(\d+\.)|(-\s\[(\s|x)\]))
              \s(?<text>\S.*)$/x
      # rubocop:enable Lint/MixedRegexpCaptureTypes

      def self.level_bullet_text(line)
        mdt = RGX.match(line)
        [mdt[:spaces].length, mdt[:bullet], mdt[:text]] if mdt
      end

      # :reek:ControlParameter
      def self.style(check)
        case check
        when ' '
          %q( style="list-style-type: '&#9744; '")
        when 'x'
          %q( style="list-style-type: '&#9745; '")
        else
          ''
        end
      end

      def self.type(bullet)
        bullet[0] =~ /\d/ ? 'ol' : 'ul'
      end
    end

    @@parsers << :list

    # category: method
    # :reek:DuplicateMethodCall :reek:TooManyStatements
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def list
      return false unless (level, bullet, text = List.level_bullet_text(@line))

      type = List.type(bullet)
      @html << "<#{type}#{@attributes.shift}>\n"
      loop do
        style = List.style(bullet[3])
        @html << "  <li#{style}>#{inline(text)}</li>\n"
        current, bullet, text = List.level_bullet_text(line_gets)
        if current&.>(level)
          list
          current, bullet, text = List.level_bullet_text(@line)
        end
        break unless current.eql?(level) && type.eql?(List.type(bullet))
      end
      @html << "</#{type}>\n"
      true
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
