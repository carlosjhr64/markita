# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    module CodeBlock
      RGX = /^ {4}(.*)$/
    end

    PARSERS << :code_block

    def code_block
      return false unless (md = CodeBlock::RGX.match(@line))

      @html << "<pre#{@attributes.shift}>\n"
      while md
        @html << "#{md[1]}\n"
        md = CodeBlock::RGX.match(@line = @file.gets)
      end
      @html << "</pre>\n"
      true
    end
  end
end
