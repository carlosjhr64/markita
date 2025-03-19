# frozen_string_literal: true

# Markita namespace
module Markita
  # Base class of the Sinatra Markita application
  class Base
    get '/readme.html' do
      Markdown.new('README').markdown File.read File.join(APPDIR, 'README.md')
    end
  end
end
