# frozen_string_literal: true

# Markita namespace
module Markita
  # Base class of the Sinatra Markita application
  class Base
    HEADER_LINKS <<
      %(\n<link rel="icon" type="image/x-icon" href="/favicon.ico">)

    module Favicon
      ICO = File.read PATH['favicon.ico']
    end

    get '/favicon.ico' do
      headers 'Content-Type' => 'image/x-icon'
      Favicon::ICO
    end
  end
end
