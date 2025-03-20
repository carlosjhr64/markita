# frozen_string_literal: true

# Markita top level namespace
module Markita
  VERSION = '6.0.250320'

  def self.run!
    require_relative 'markita/requires'
    Base.run!
  end
end
