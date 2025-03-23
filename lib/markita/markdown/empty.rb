# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Empty
      RGX = /^$/
    end

    @@parsers << :empty

    def empty
      return false unless Empty::RGX.match?(@line)

      @line = @file.gets
      true
    end
  end
end
