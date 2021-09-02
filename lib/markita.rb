module Markita
  VERSION = '2.0.210902'

  def self.run!
    # Standard libraries
    require 'digest'
    require 'cgi'
    # Gems
    require 'rouge'
    require 'sinatra/base'
    require 'thin'
    # Local
    require_relative 'markita/config.rb'
    require_relative 'markita/markdown.rb'
    require_relative 'markita/base.rb'
    # Plugs
    require_relative 'markita/plug/favicon.rb'    unless OPTIONS&.no_favicon
    require_relative 'markita/plug/highlight.rb'  unless OPTIONS&.no_highlight
    require_relative 'markita/plug/login.rb'      unless OPTIONS&.no_login
    require_relative 'markita/plug/about.rb'      unless OPTIONS&.no_about
    require_relative 'markita/plug/plugs.rb'      unless OPTIONS&.no_plugs
    Base.run!
  end
end
