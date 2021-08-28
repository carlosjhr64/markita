module MDServer
  VERSION = '1.0.210827'

  def self.run!
    # Standard libraries
    require 'digest'
    require 'cgi'
    # Gems
    require 'sinatra/base'
    require 'rouge'
    require 'kramdown'
    require 'thin'
    Tilt.register Tilt::KramdownTemplate, 'md'
    # Local
    require_relative 'mdserver/config.rb'
    require_relative 'mdserver/base.rb'
    # Plugs
    require_relative 'mdserver/plug/favicon.rb'    unless OPTIONS&.no_favicon
    require_relative 'mdserver/plug/highlight.rb'  unless OPTIONS&.no_highlight
    require_relative 'mdserver/plug/login.rb'      unless OPTIONS&.no_login
    require_relative 'mdserver/plug/about.rb'      unless OPTIONS&.no_about
    require_relative 'mdserver/plug/plugs.rb'      unless OPTIONS&.no_plugs
    Base.run!
  end
end
