# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module CodeBlock
      RGX = /^ {4}(.*)$/
    end

    @@parsers << :code_block

    # category: method
    # :reek:TooManyStatements
    def code_block
      return false unless (md = CodeBlock::RGX.match(@line))

      @html << "<pre#{@attributes.shift}>\n"
      while md
        @html << "#{md[1]}\n"
        md = CodeBlock::RGX.match(@line = @string_getter.gets)
      end
      @html << "</pre>\n"
      true
    end
  end
end
