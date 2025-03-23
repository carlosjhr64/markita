# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Markup
      RGX = /^ {0,3}<.*>$/
    end

    @@parsers << :html_markup

    def html_markup
      return false unless Markup::RGX.match(@line)

      @html << @line
      @line = @string_getter.gets
      true
    end
  end
end
