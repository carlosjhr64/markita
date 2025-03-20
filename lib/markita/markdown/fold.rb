# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
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

    PARSERS << :fold

    # Fold with optional metadata
    # :reek:DuplicateMethodCall ok here
    def fold
      return false unless Fold::RGX.match?(@line)

      @line = @file.gets
      until Fold::RGX.match?(@line)
        @line = Fold.scrape4metadata(@line, @metadata, @file)
      end
      @line = @file.gets
      true
    end
  end
end
