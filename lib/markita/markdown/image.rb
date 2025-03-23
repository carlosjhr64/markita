# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Image
      RGX = /^!\[([^\[\]]+)\]\(([^()]+)\)$/

      def self.attributes(line)
        mdt = RGX.match(line)
        [mdt[1], *mdt[2].strip.split(/\s+/, 2)] if mdt
      end

      def self.img_src(src, alt, att)
        style = Image.style(alt)
        size = Image.size(alt)
        %(<img src="#{src}"#{style}#{size}alt="#{alt.strip}"#{att.shift}>\n)
      end

      def self.size(alt)
        if (mdt = /(\d+)x(\d+)/.match(alt))
          %(width="#{mdt[1]}" height="#{mdt[2]}" )
        else
          ''
        end
      end

      # :reek:ControlParameter
      def self.style(alt)
        case alt
        when /^:.*:$/
          %( style="display: block; margin-left: auto; margin-right: auto;" )
        when /:$/
          %( style="float:left;" )
        when /^:/
          %( style="float:right;" )
        else
          ' '
        end
      end
    end

    @@parsers << :images

    # category: method
    # :reek:TooManyStatements
    def images
      return false unless (alt, src, href = Image.attributes(@line))

      @html << %(<a href="#{href}">\n) if href
      @html << Image.img_src(src, alt, @attributes)
      @html << %(</a>\n) if href
      line_gets
      true
    end
  end
end
