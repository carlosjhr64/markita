# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Heading
      RGX = /^(\#{1,6}) (.*)$/

      def self.level_header(line)
        mdt = RGX.match(line)
        [mdt[1].length, mdt[2]] if mdt
      end
    end

    @@parsers << :heading

    # category: method
    # :reek:TooManyStatements :reek:UncommunicativeVariableName
    def heading
      return false unless (n, header = Heading.level_header(@line))

      id = header.gsub(/\([^()]*\)/, '').scan(/\w+/).join('+')
      @html << %(<a id="#{id}">\n)
      @html << "  <h#{n}#{@attributes.shift}>#{inline(header)}</h#{n}>\n"
      @html << "</a>\n"
      @line = @string_getter.gets
      true
    end
  end
end
