module Markita
  VERSION = '5.0.240929'

  def self.run!
    # Standard libraries
    require 'digest'
    require 'cgi'
    require 'openssl'
    # Gems
    require 'rouge'
    require 'webrick/https'
    require 'sinatra/base'
    # Local
    require_relative 'markita/config'
    require_relative 'markita/html'
    require_relative 'markita/preprocess'
    require_relative 'markita/markdown'
    require_relative 'markita/base'
    # Plugs
    require_relative 'markita/plug/about'      unless OPTIONS.no_about
    require_relative 'markita/plug/favicon'    unless OPTIONS.no_favicon
    require_relative 'markita/plug/highlight'  unless OPTIONS.no_highlight
    require_relative 'markita/plug/login'      unless OPTIONS.no_login
    require_relative 'markita/plug/navigation' unless OPTIONS.no_navigation
    require_relative 'markita/plug/plugs'      unless OPTIONS.no_plugs
    require_relative 'markita/plug/readme'     unless OPTIONS.no_readme
    Base.run!
  end
end
# Requires:
#`ruby`
