# frozen_string_literal: true

module Pico::Case
  class Result
    attr_reader :data

    # rubocop:disable Naming/MethodName
    def self.Success(**data)
      raise ArgumentError if data.empty?

      new(:success, data)
    end

    def self.Failure(**data)
      raise ArgumentError if data.empty?

      new(:failure, data)
    end
    # rubocop:enable Naming/MethodName

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

    def on_success
      yield(**data) if block_given? && success?

      self
    end

    def on_failure
      yield(**data) if block_given? && failure?

      self
    end

    private_class_method :new

    private

    attr_reader :type

    def respond_to_missing?(name, include_private = false)
      @data.respond_to?(name, include_private)
    end

    def method_missing(method, *args, &block)
      @data.send(method, *args, &block)
    end
  end
end
