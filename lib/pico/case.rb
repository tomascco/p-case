# frozen_string_literal: true

require_relative "case/version"

module Pico
  module Case
    class Error < StandardError; end

    class Result
      attr_reader :type, :data

      def self.Success(**data)
        new(:success, data)
      end

      def self.Failure(**data)
        new(:failure, data)
      end

      def initialize(type, data)
        @type = type
        @data = data
      end

      def success?
        type == :success
      end

      def failure?
        !success?
      end

      def then(&block)
        return self if failure?
        raise LocalJumpError if block.nil?

        block_result = Result.module_exec(**data, &block)

        raise ArgumentError unless block_result.is_a?(Result)

        block_result
      end

      private

      def respond_to_missing?(name, include_private = false)
        @data.respond_to?(name, include_private)
      end

      def method_missing(method, *args, &block)
        @data.send(method, *args, &block)
      end
    end

    def self.new(...)
      Result::Success(...)
    end
  end
end
