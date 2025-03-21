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

    PARSERS << :horizontal_rule

    # category: method
    def horizontal_rule
      return false unless HorizontalRule::RGX.match?(@line)

      @line = @file.gets
      # Display HR
      @html << "<hr#{@attributes.shift}>\n"
      true
    end
  end
end
