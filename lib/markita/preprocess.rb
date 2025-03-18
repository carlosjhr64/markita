# frozen_string_literal: true

# Markita namespace
module Markita
  # Preprocess template lines
  class Preprocess
    def initialize(file)
      @file = file.is_a?(String) ? StringIO.new(file) : file
      @line = @mdt = @rgx = @template = nil
    end

    def template_line
      line = @template || @line
      @mdt.named_captures.each do |name, value|
        line = line.gsub("&#{name.downcase};", value)
        line = line.gsub("&#{name.upcase};", CGI.escape(value))
      end
      line
    end

    def rgx_set = (@rgx = Regexp.new @mdt[1]) && nil
    def template_set = (@template = "#{@mdt[1]}\n") && nil

    def preprocess
      return template_line if (@mdt = @rgx&.match(@line))
      return rgx_set if (@mdt = %r{^! regx = /(.*)/$}.match(@line))
      return template_set if (@mdt = /^! template = "(.*)"$/.match(@line))

      @rgx &&= (@template = nil)
      @line
    end

    def gets
      while (@line = @file.gets)
        if (line = preprocess)
          return line
        end
      end
      nil
    end
  end
end
