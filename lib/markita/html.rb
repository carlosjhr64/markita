# frozen_string_literal: true

# Markita namespace
module Markita
  # HTML template
  # :reek:ClassVariable
  # rubocop:disable Style/ClassVars
  module Html
    # category: header

    def self.header(title)
      <<~HEADER
        <!DOCTYPE html>
        <html>
        <head>
        <title>#{title}</title>
        #{@@header_links}</head>
        <body>
      HEADER
    end

    @@header_links = String.new(HEADER_LINKS)
    def self.header_links = @@header_links

    # category: body

    @@navigation = String.new(NAVIGATION)
    def self.navigation = @@navigation

    # category: footer

    def self.footer
      <<~FOOTER
        </body>
        </html>
      FOOTER
    end
  end
  # rubocop:enable Style/ClassVars
end
