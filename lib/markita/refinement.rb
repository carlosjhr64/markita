# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Utility methods as refinements
  module Refinement
    refine String do
      def template(named_captures)
        template = dup
        named_captures.each { |key, value| template.template!(key, value) }
        template
      end

      def template!(key, value)
        gsub!("&#{key.downcase};", value)
        gsub!("&#{key.upcase};", CGI.escape(value))
      end
    end
  end
end
