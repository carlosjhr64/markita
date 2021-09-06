module Markita
module HTML
  def HTML.header(key)
    <<~HEADER
      <!DOCTYPE html>
      <html>
      <head>
        <title>#{key}</title>
      #{HEADER_LINKS}</head>
      <body>
    HEADER
  end

  def HTML.footer
    <<~FOOTER
      </body>
      </html>
    FOOTER
  end
end
end
