# frozen_string_literal: true

# Markita top level namespace
module Markita
  VERSION = '5.0.250318'

  def self.run!
    require_relative 'markita/requires'
    Base.run!
  end
end
