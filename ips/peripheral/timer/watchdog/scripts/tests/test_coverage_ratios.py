import sys
from pathlib import Path
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from summarize_coverage import ratios


def test_urg_ratios_preserve_denominators_and_absent_metrics():
    actual = ratios('32.40 21.64 1199/5541 -- -- 0.00 0/264 dut', ['line', 'assertion', 'fsm'])
    assert actual['line']['covered'] == 1199
    assert actual['line']['total'] == 5541
    assert actual['assertion'] is None
    assert actual['fsm']['achieved'] == 0


@pytest.mark.parametrize('row', ['90.0 90.0 1/2', '0 0 0/0', '100 100 2/1', '50 50'])
def test_malformed_or_conflicting_urg_rows_fail(row):
    with pytest.raises(ValueError):
        ratios(row, ['line'])
