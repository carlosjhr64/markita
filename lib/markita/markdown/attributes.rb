# frozen_string_literal: true

# Markita top level namespace
module Markita
  using Refinement
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    module Attributes
      RGX = /^\{:( [^\{\}]+)\}/
    end

    PARSERS << :attributes

    def attributes
      return false unless (md = Attributes::RGX.match(@line))

      @attributes.push md[1]
      @line = md.post_match
      true
    end
  end
end
