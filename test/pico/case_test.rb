# frozen_string_literal: true

require "test_helper"

module Pico
  class CaseTest < Minitest::Test
    def test_pcase_creation_with_new
      # Arrange & Act
      pcase = nil
      Case::Result.stub(:Success, :pcase) do
        pcase = Case.new(number: 5)
      end

      # Assert
      assert_equal(:pcase, pcase)
    end
  end
end
