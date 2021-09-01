module Markita
class Base
  module About
    def self.page
      text = <<~TEXT
        # [Markita](https://github.com/carlosjhr64/markita)

        * VERSION: #{VERSION}
        * ROOT: #{ROOT.sub(%r{^/home/\w+/},'~/')}
        * ARGV: #{ARGV.join(' ')}
        * START_TIME: #{START_TIME}

        ## Plug.html routes:

      TEXT
      Base.routes['GET'].each do |route|
        path = route[0].to_s
        next  unless %r{^/\w+\.html$}.match? path
        basename = File.basename(path, '.*')
        text << "* [#{basename}](#{path})\n"
      end
      if defined? Favicon and Favicon::ICO
        text << "\n![Favicon](/favicon.ico)\n"
      end
      text
    end
  end

  get '/about.html' do
    Base.page 'about', About.page
  end
end
end
