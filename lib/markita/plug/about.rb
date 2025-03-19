# frozen_string_literal: true

# Markita namespace
module Markita
  # Base class of the Sinatra Markita application
  class Base
    # About namespace to support the /about.html route
    module About
      ABOUT_TEXT = <<~TEXT.freeze
        # [Markita](https://github.com/carlosjhr64/markita)

        * VERSION: #{VERSION}
        * ROOT: #{ROOT.sub(%r{^/home/\w+/}, '~/')}
        * ARGV: #{ARGV.join(' ')}
        * START_TIME: #{START_TIME}

        ## Plug.html routes:

      TEXT

      def self.plugs
        Base.routes['GET'].each do |route|
          path = route[0].to_s
          next unless %r{^/\w+\.html$}.match? path

          yield path, File.basename(path, '.*')
        end
      end

      def self.page
        text = ABOUT_TEXT.dup
        plugs { |path, basename| text << "* [#{basename}](#{path})\n" }
        if defined? Favicon && Favicon::ICO
          text << "\n![Favicon](/favicon.ico)\n"
        end
        text
      end
    end

    get '/about.html' do
      Markdown.new('About').markdown About.page
    end
  end
end
