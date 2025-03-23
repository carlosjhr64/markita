# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Script
      RGX = /^<script/
    end

    @@parsers << :script

    # :reek:TooManyStatements :reek:DuplicateMethodCall
    def script
      return false unless Script::RGX.match(@line)

      @html << @line
      while (@line = @string_getter.gets)
        @html << @line
        break if %r{^</script>}.match?(@line)
      end
      @line = @string_getter.gets if @line
      true
    end
  end
end
