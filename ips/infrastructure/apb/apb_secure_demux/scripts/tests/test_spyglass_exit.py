"""The warnings-only adapter must never mask a failed commercial run."""
import runpy
from pathlib import Path

import pytest

accepted = runpy.run_path(str(Path(__file__).resolve().parents[1] / 'tool_adapters/sg_shell'))['accepted']
SUMMARY = 'Reported Messages: 0 Fatals, 0 Errors, 12 Warnings\n'
WARNING = 'SpyGlass run failed: Rule-checking completed with warnings (11)\n'


def test_accepts_native_warning_completion():
    assert accepted(11, SUMMARY + WARNING)


@pytest.mark.parametrize('code,text', [
    (1, SUMMARY + WARNING), (11, SUMMARY), (11, WARNING),
    (11, SUMMARY.replace('0 Errors', '1 Errors') + WARNING),
    (11, SUMMARY.replace('0 Fatals', '1 Fatals') + WARNING),
    (11, 'ERROR: license checkout failed\n' + SUMMARY + WARNING),
    (11, 'Reported Messages: 1 Fatals, 0 Errors, 0 Warnings\n' + SUMMARY + WARNING),
])
def test_rejects_failure_or_incomplete_evidence(code, text):
    assert not accepted(code, text)
