# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    module Empty
      RGX = /^$/
    end

    PARSERS << :empty

    def empty
      return false unless Empty::RGX.match?(@line)

      @line = @file.gets
      true
    end
  end
end
