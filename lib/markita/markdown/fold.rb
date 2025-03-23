# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    module Fold
      RGX = /^[-.]{3} #/
      METADATA = /^(\w+): (.*)$/
      def self.scrape4metadata(line, metadata, file)
        if (md = Fold::METADATA.match(line))
          metadata[md[1]] = md[2]
        end
        file.gets
      end
    end

    @@parsers << :fold

    # category: method
    # :reek:DuplicateMethodCall ok here
    def fold
      return false unless Fold::RGX.match?(@line)

      # Fold with optional metadata
      line_gets
      until Fold::RGX.match?(@line)
        @line = Fold.scrape4metadata(@line, @metadata, @line_getter)
      end
      line_gets
      true
    end
  end
end
