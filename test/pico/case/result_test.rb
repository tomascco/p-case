# frozen_string_literal: true

require "test_helper"

module Pico::Case
  class ResultTest < Minitest::Test
    # rubocop:disable Naming/MethodName
    def test_Success
      # Arrange
      pcase = Result::Success(number: 5)

      # Assert
      assert_kind_of(Result, pcase)
      assert_equal({number: 5}, pcase.data)
      assert_predicate(pcase, :success?)

      # --

      # FACT: this method only accept keyword arguments
      assert_raises(ArgumentError) { Result::Success({number: 5}) }
      assert_raises(ArgumentError) { Result::Success("string", 5) }

      # FACT: no keyword arguments raises an argument error
      assert_raises(ArgumentError) { Result::Success() }
    end

    def test_Failure
      # Arrange
      pcase = Result::Failure(number: 5)

      # Assert
      assert_kind_of(Result, pcase)
      assert_equal({number: 5}, pcase.data)
      assert_predicate(pcase, :failure?)

      # --

      # FACT: this method only accept keyword arguments
      assert_raises(ArgumentError) { Result::Failure({number: 5}) }
      assert_raises(ArgumentError) { Result::Failure("string", 5) }

      # FACT: no keyword arguments raises an argument error
      assert_raises(ArgumentError) { Result::Failure() }
    end
    # rubocop:enable Naming/MethodName

    def test_then_accumulation_on_success
      # Arrange
      pcase = Result::Success(number: 1)

      # Act
      result = pcase
        .then { |number:| Success(number: number + 1) }
        .then { |number:| Success(number: number + 1) }

      # Assert
      assert_kind_of(Result, result)
      assert_predicate(result, :success?)
      assert_equal(3, result[:number])
    end

    def test_then_accumulation_on_failure
      # Arrange
      pcase = Result::Success(number: 1)

      # Act
      result = pcase
        .then { |number:| Failure(number: number + 1) }
        .then { |number:| Success(number: number + 1) }
        .then { |number:| Failure(number: number + 1) }

      # Assert
      assert_kind_of(Result, result)
      assert_predicate(result, :failure?)
      assert_equal(2, result[:number])
    end

    def test_then_exceptions
      # Arrange
      pcase = Result::Success(number: 1)

      # Act + Assert
      assert_raises(LocalJumpError) do
        pcase.then
      end

      assert_raises(ArgumentError) do
        pcase.then { :not_an_result }
      end
    end

    def test_method_missing_redirection_to_data
      # Arrange
      pcase = Result::Success(number: 1, letter: "a")

      # Act & Assert
      assert_respond_to(pcase, :[])
      assert_equal(1, pcase[:number])

      assert_respond_to(pcase, :values_at)
      assert_equal([1, "a"], pcase.values_at(:number, :letter))
    end

    def test_on_success
      # Arrange
      pcase = Result::Success(number: 1, letter: "a")
      count = 0

      # Act
      result = pcase
        .on_success { count += 1 }
        .on_failure { count += 1 }
        .on_success { count += 1 }

      # Assert
      assert_equal(2, count)
      assert_equal(pcase, result)
    end

    def test_on_failure
      # Arrange
      pcase = Result::Failure(number: 1, letter: "a")
      count = 0

      # Act
      result = pcase
        .on_failure { count += 1 }
        .on_success { count += 1 }
        .on_failure { count += 1 }

      # Assert
      assert_equal(2, count)
      assert_equal(pcase, result)
    end
  end
end
