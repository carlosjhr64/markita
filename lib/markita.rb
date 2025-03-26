# frozen_string_literal: true

# Markita top level namespace
# :reek:ClassVariable
# rubocop:disable Style/ClassVars
module Markita
  VERSION = '6.0.250326'

  @@no = []
  def self.no = @@no

  def self.run!
    require_relative 'markita/requires'
    # Requiring the markdown elements:
    Dir.glob("#{__dir__}/markita/markdown/*.rb")
       .map { File.basename(it, '.rb') }
       .each { require_relative "markita/markdown/#{it}" }
    Base.run!
  end
end
# rubocop:enable Style/ClassVars
