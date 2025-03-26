# frozen_string_literal: true

# Standard libraries
require 'English'
require 'digest'
require 'cgi'
require 'openssl'
# Gems
require 'colorize'
require 'rouge'
require 'webrick/https'
require 'sinatra/base'
# Local
require_relative 'refinement'
require_relative 'config'
require_relative 'html'
require_relative 'preprocess'
require_relative 'markdown'
require_relative 'base'
# Plugs
require_relative 'plug/about'      unless Markita.no.include? :about
require_relative 'plug/favicon'    unless Markita.no.include? :favicon
require_relative 'plug/highlight'  unless Markita.no.include? :highlight
require_relative 'plug/login'      unless Markita.no.include? :login
require_relative 'plug/navigation' unless Markita.no.include? :navigation
require_relative 'plug/plugs'      unless Markita.no.include? :plugs
require_relative 'plug/readme'     unless Markita.no.include? :readme
# Requires:
# `ruby`
