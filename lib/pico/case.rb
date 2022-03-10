# frozen_string_literal: true

require_relative "case/version"
require_relative "case/result"

module Pico
  module Case
    class Error < StandardError; end

    def self.new(...)
      Result::Success(...)
    end
  end
end
