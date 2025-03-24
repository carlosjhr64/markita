# frozen_string_literal: true

# Markita namespace
module Markita
  Html.header_links <<
    %(<link rel="icon" type="image/x-icon" href="/favicon.ico">\n)

  # Base class of the Sinatra Markita application
  class Base
    module Favicon
      ICO = File.read PATH['favicon.ico']
    end

    get '/favicon.ico' do
      headers 'Content-Type' => 'image/x-icon'
      Favicon::ICO
    end
  end
end
