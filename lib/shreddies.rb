# frozen_string_literal: true

require 'shreddies/version'
require 'shreddies/engine'

module Shreddies
  class Error < StandardError; end

  autoload :Json, 'shreddies/json'
end
