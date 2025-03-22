# frozen_string_literal: true

# Markita top level namespace
module Markita
  # Markdown namespace
  # :reek:InstanceVariableAssumption in markdown.rb
  class Markdown
    # Module to isolate from Markdown
    module Embed
      RGX = /^!> (#{PAGE_KEY}\.\w+)$/

      def self.code(filename, lang)
        code = File.read(filename)
        lang ? ROUGE.format(lang.new.lex(code)) : code
      end

      # :reek:TooManyStatements
      def self.ext_klass_lang(filename, lang = nil)
        extension = filename.split('.').last
        unless extension == 'html'
          lang = Rouge::Lexer.find(extension) unless extension == 'txt'
          klass = lang ? ' class="highlight"' : ''
          return [true, klass, lang]
        end
        [false, nil, nil]
      end

      def self.filename(line)
        if (mdt = RGX.match(line))
          mdt[1]
        end
      end
    end

    PARSERS << :embed

    # category: method
    # :reek:TooManyStatements
    # rubocop:disable Metrics/MethodLength
    def embed
      return false unless (filename = Embed.filename(@line))

      if File.exist?(filename = File.join(ROOT, filename))
        code, klass, lang = Embed.ext_klass_lang(filename)
        if code
          @html << "<pre#{klass}#{@attributes.shift}>"
          @html << '<code>' if lang
          @html << "\n"
        end
        @html << Embed.code(filename, lang)
        if code
          @html << '</code>' if lang
          @html << "</pre>\n"
        end
      else
        @html << @line
      end
      @line = @file.gets
      true
    end
    # rubocop:enable Metrics/MethodLength
  end
end
