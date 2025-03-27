# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption :reek:ClassVariable
  class Markdown
    # Module to isolate from Markdown
    # :reek:DuplicateMethodCall
    module Fold
      RGX = /^[-.]{3} #/
      METADATA = /^(\w+): (.*)$/
      def self.scrape4metadata(line, metadata, attributes)
        if (md = Fold::METADATA.match(line))
          if (key = md[1]) == 'attributes'
            attributes.push " #{md[2]}"
          else
            metadata[key] = md[2]
          end
        end
      end
    end

    @@parsers << :fold

    # category: method
    # :reek:DuplicateMethodCall ok here
    def fold
      return false unless Fold::RGX.match?(@line)

      # Fold with optional metadata
      until Fold::RGX.match?(line_gets)
        Fold.scrape4metadata(@line, @metadata, @attributes)
      end
      line_gets
      true
    end
  end
end
