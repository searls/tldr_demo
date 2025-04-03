class QuiteSlow < TLDR
  def test_pretty_slow
    sleep 0.8
    assert true
  end
end
