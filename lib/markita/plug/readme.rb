module Markita
class Base
  get '/readme.html' do
    Markdown.new('README').markdown File.read File.join(APPDIR,'README.md')
  end
end
end
