# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption variables in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    module HorizontalRule
      RGX = /^---+$/
    end

    # Horizontal rule
    PARSERS << :horizontal_rule
    def horizontal_rule
      HorizontalRule::RGX.match?(@line) or return false
      @line = @file.gets
      # Display HR
      @html << "<hr#{@attributes.shift}>\n"
      true
    end
  end
end
