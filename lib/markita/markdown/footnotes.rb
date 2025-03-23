# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Footnotes
      RGX = /^\[\^\d+\]:/
    end

    @@parsers << :footnotes

    # :reek:TooManyStatements
    def footnotes
      return false unless (continue = Footnotes::RGX.match?(@line))

      @html << "<small>\n"
      while continue
        @html << "#{inline(@line.chomp)}<br>\n"
        continue = Footnotes::RGX.match?(@line = @file.gets)
      end
      @html << "</small>\n"
      true
    end
  end
end
