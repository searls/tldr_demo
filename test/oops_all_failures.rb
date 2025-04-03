class OopsAllFailures < TLDR
  def test_fail_fail
    fail "Did you know fail is actually an alias of raise?"
  end

  def test_refute_true_fail
    refute true
  end

  def test_assert_false_fail
    assert false
  end
end
