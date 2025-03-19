# frozen_string_literal: true

# Markita namespace
module Markita
  HEADER_LINKS <<
    %(\n<link rel="stylesheet" href="/highlight.css" type="text/css">)
  # Base class of the Sinatra Markita application
  class Base
    # Highlight namespace to support the /highlight.css route
    module Highlight
      theme = OPTIONS.theme || 'base16.light'
      CSS = Rouge::Theme.find(theme)&.render(scope: '.highlight')
      raise "Can't find Rouge Theme #{theme}" unless CSS
    end

    get '/highlight.css' do
      headers 'Content-Type' => 'text/css'
      Highlight::CSS
    end
  end
end
