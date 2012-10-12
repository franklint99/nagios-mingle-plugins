$: << File.expand_path("../../lib", File.dirname(__FILE__))
require "test/unit"
require "base_check"

class BaseCheckTest < Test::Unit::TestCase
  def setup
    @check = MingleNagiosChecks::BaseCheck.new
  end

  def test_in_range_with_simple_number
    assert !(@check.alert_for_range? "10", 9), "9 should not alert for range (0, 10)"
    assert !(@check.alert_for_range? "10", 10), "should include upper bound"
    assert !(@check.alert_for_range? "10", 0), "should include lower bound (implied to be 0)"
    assert (@check.alert_for_range? "10", -1), "-1 should be out of lower bounds"
    assert (@check.alert_for_range? "10", 11), "11 should be out of upper bounds"
  end

  def test_in_range_greater_than_or_equal_to
    assert !(@check.alert_for_range? "10:", 10), "range is inclusive, 10 should be in the range '10:' (same as >= 10)"
    assert !(@check.alert_for_range? "10:", 11), "11 should be in the range '10:' (same as >= 10)"
    assert (@check.alert_for_range? "10:", 9), "9 should be out of range '10:' (same as >= 10)"
  end

  def test_in_range_less_than_or_equal_to
    assert !(@check.alert_for_range? "~:10", -1), "negative numbers like -1 should be in the range '~:10' (same as <= 10)"
    assert !(@check.alert_for_range? "~:10", 9), "9 should be in the range '~:10' (same as <= 10)"
    assert !(@check.alert_for_range? "~:10", 10), "range is inclusive, 10 should be in the range '~:10' (same as <= 10)"
    assert (@check.alert_for_range? "~:10", 11), "11 should be out of range '~:10' (same as <= 10)"
  end

  def test_in_range_with_explicit_range
    assert !(@check.alert_for_range? "10:20", 10), "lower bound 10 should be in the range '10:20' (same as 10..20, inclusive)"
    assert !(@check.alert_for_range? "10:20", 15), "15 should be in the range '10:20' (same as 10..20, inclusive)"
    assert !(@check.alert_for_range? "10:20", 20), "upper bound 20 should be in the range '10:20' (same as 10..20, inclusive)"
    assert (@check.alert_for_range? "10:20", 21), "21 should be out of the range '10:20' (same as 10..20, inclusive)"
    assert (@check.alert_for_range? "10:20", 9), "9 should be out of the range '10:20' (same as 10..20, inclusive)"
    assert (@check.alert_for_range? "10:20", -1), "negative numbers like -1 should be out of the range '10:20' (same as 10..20, inclusive)"
  end

  def test_in_range_with_explicit_exclusive_range
    assert (@check.alert_for_range? "@10:20", 10), "lower bound 10 should be out of the range '@10:20' (same as outside of 10..20, inclusive)"
    assert (@check.alert_for_range? "@10:20", 15), "15 should be out of the range '@10:20' (same as outside of 10..20, inclusive)"
    assert (@check.alert_for_range? "@10:20", 20), "upper bound 20 should be out of the range '@10:20' (same as outside of 10..20, inclusive)"
    assert !(@check.alert_for_range? "@10:20", 21), "21 should be in the range '@10:20' (same as outside of 10..20, inclusive)"
    assert !(@check.alert_for_range? "@10:20", 9), "9 should be in the range '@10:20' (same as outside of 10..20, inclusive)"
    assert !(@check.alert_for_range? "@10:20", -1), "negative numbers like -1 should be in the range '@10:20' (same as outside of 10..20, inclusive)"
  end

  def test_in_range_raises_error_when_cannot_parse_range
    begin
      @check.alert_for_range? ":2:", 2
      assert false, "I should not have gotten through - this message is more for documentation since it's impossible to reach"
    rescue
      assert true, "I should raise an error when I can't parse the range - this message is more for documentation since it's impossible to reach"
    end
  end

end