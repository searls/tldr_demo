require_relative "calculator/adder"
require_relative "calculator/subtractor"

class Calculator
  def initialize
    @adder = Adder.new
    @subtractor = Subtractor.new
  end

  def add(*numbers)
    numbers.reduce(0) { |memo, n|
      @adder.add(n, to: memo)
    }
  end

  def subtract(*numbers)
    numbers.reduce { |memo, n|
      @subtractor.subtract(n, from: memo)
    }
  end
end
