# frozen_string_literal: true

# Markita namespace
module Markita
  # Preprocess template lines
  class Preprocess
    using Refinement
    # State variables that change as lines are read
    IterationVariables = Struct.new(:line, :rgx, :template, :captures) do
      def line2rgx
        if (mdt = %r{^! regx = /(.*)/$}.match(line))
          self.rgx = Regexp.new(mdt[1])
        end
      end

      def line2template
        if (mdt = /^! template = "(.*)"$/.match(line))
          self.template = "#{mdt[1]}\n"
        end
      end

      def line2captures
        if (mdt = rgx.match(line))
          self.captures = mdt.named_captures
        else
          self.rgx = self.template = nil
        end
      end

      def next?(line)
        self.line = line
        return true if line2rgx || line2template

        line2captures if rgx
        false
      end

      def to_s
        return (template || line).template(captures) if captures

        line
      end
    end

    def gets
      while (line = @string_getter.gets)
        next if @iv.next?(line)

        return @iv.to_s
      end
      nil
    end

    def initialize(string_getter)
      @string_getter = string_getter
      @iv = IterationVariables.new
    end
  end
end
