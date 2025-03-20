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
require_relative 'plug/about'      unless OPTIONS.no_about?
require_relative 'plug/favicon'    unless OPTIONS.no_favicon?
require_relative 'plug/highlight'  unless OPTIONS.no_highlight?
require_relative 'plug/login'      unless OPTIONS.no_login?
require_relative 'plug/navigation' unless OPTIONS.no_navigation?
require_relative 'plug/plugs'      unless OPTIONS.no_plugs?
require_relative 'plug/readme'     unless OPTIONS.no_readme?
# Requires:
# `ruby`
