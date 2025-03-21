# frozen_string_literal: true

# Markita top level namespace
module Markita
  VERSION = '6.0.250321'

  def self.run!
    require_relative 'markita/requires'
    # Requiring the markdown elements:
    Dir.glob("#{__dir__}/markita/markdown/*.rb")
       .map { File.basename(it, '.rb') }
       .each { require_relative "markita/markdown/#{it}" }
    Base.run!
  end
end
