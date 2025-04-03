class Calculator
  class SubtractorTest < TLDR
    def setup
      @subject = Subtractor.new
    end

    def test_subtract
      bananas = 3
      banana_stand = 99

      result = @subject.subtract(bananas, from: banana_stand)

      assert_equal 96, result
    end
  end
end
