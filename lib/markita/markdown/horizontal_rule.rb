# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module HorizontalRule
      RGX = /^---+$/
    end

    @@parsers << :horizontal_rule

    # category: method
    def horizontal_rule
      return false unless HorizontalRule::RGX.match?(@line)

      @line = @string_getter.gets
      # Display HR
      @html << "<hr#{@attributes.shift}>\n"
      true
    end
  end
end
