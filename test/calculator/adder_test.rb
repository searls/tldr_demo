class Calculator
  class AdderTest < TLDR
    def setup
      @subject = Adder.new
    end

    def test_add
      bank_account = 1.23
      paycheck = 40.22

      result = @subject.add(paycheck, to: bank_account)

      assert_in_delta 41.45, result, 0.001
    end
  end
end
