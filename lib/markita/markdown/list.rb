# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    module List
    end
  end
end
