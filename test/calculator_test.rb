class CalculatorTest < TLDR
  def setup
    @subject = Calculator.new
  end

  def test_add
    assert_equal 2, @subject.add(1, 1)
    assert_equal 3, @subject.add(1, 1, 1)
    assert_equal 4, @subject.add(1, 1, 1, 1)
    assert_equal 4, @subject.add(2, 2)
  end

  def test_adding_nonsense
    e = assert_raises {
      @subject.add(1, :pizza)
    }
    assert_equal "undefined method '+' for an instance of Symbol", e.message
  end

  def test_subtract
    assert_equal 1, @subject.subtract(2, 1)
    assert_equal 2, @subject.subtract(4, 1, 1)
    assert_equal 2, @subject.subtract(8, 3, 2, 1)
    assert_equal(-2, @subject.subtract(2, 4))
  end

  def test_subtracting_nonsense
    e = assert_raises {
      @subject.subtract(42, ObjectSpace)
    }
    assert_equal "Module can't be coerced into Integer", e.message
  end
end
