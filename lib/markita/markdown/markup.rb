# frozen_string_literal: true

# Markita top level namespace
module Markita
  using Refinement
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    module Markup
      RGX = /^ {0,3}<.*>$/
    end

    PARSERS << :html_markup

    def html_markup
      return false unless Markup::RGX.match(@line)

      @html << @line
      @line = @file.gets
      true
    end
  end
end
