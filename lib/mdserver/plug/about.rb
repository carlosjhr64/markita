module MDServer
class Base
  module About
    def self.page
      text = <<~TEXT
        # MDServer

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
      text
    end
  end

  get '/about.html' do
    Base.page('about') { markdown About.page}
  end
end
end
