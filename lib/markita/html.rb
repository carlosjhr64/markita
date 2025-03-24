# frozen_string_literal: true

# Markita namespace
module Markita
  # HTML template
  module HTML
    # category: header
    def self.header(title)
      <<~HEADER
        <!DOCTYPE html>
        <html>
        <head>
        <title>#{title}</title>#{HEADER_LINKS}
        </head>
        <body>
      HEADER
    end

    # category: body
    def self.navigation
      NAVIGATION
    end

    # category: footer
    def self.footer
      <<~FOOTER
        </body>
        </html>
      FOOTER
    end
  end
end
