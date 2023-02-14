module Markita
module HTML
  def self.header(key)
    <<~HEADER
      <!DOCTYPE html>
      <html>
      <head>
        <title>#{key}</title>
      #{HEADER_LINKS}</head>
      <body>
    HEADER
  end

  def self.navigation
    NAVIGATION
  end

  def self.footer
    <<~FOOTER
      </body>
      </html>
    FOOTER
  end
end
end
