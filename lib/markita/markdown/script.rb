# frozen_string_literal: true

# Markita top level namespace
module Markita
  using Refinement
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    module Script
      RGX = /^<script/
    end

    PARSERS << :script

    # :reek:TooManyStatements :reek:DuplicateMethodCall
    def script
      return false unless Script::RGX.match(@line)

      @html << @line
      while (@line = @file.gets)
        @html << @line
        break if %r{^</script>}.match?(@line)
      end
      @line = @file.gets if @line
      true
    end
  end
end
