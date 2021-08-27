module MDServer
  VERSION = '1.0.210827'

  def self.run!
    # Standard libraries
    require 'digest'
    require 'cgi'
    # Gems
    require 'sinatra/base'
    require 'rouge'
    Tilt.register Tilt::KramdownTemplate, 'md'
    # Local
    require_relative 'mdserver/config.rb'
    require_relative 'mdserver/base.rb'
    # Plugs
    require_relative 'mdserver/plug/login.rb'
    require_relative 'mdserver/plug/restart.rb'
    Base.run!
  end
end
