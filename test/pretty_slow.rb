class PrettySlow < TLDR
  def test_pretty_slow
    sleep 0.6
    assert true
  end
end
