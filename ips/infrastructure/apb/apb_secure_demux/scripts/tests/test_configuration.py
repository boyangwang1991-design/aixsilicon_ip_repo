"""Independent boundary checks for the integration configuration validator."""

import copy
import importlib.util
from pathlib import Path

import pytest

path = Path(__file__).parents[1] / "check_configuration.py"
spec = importlib.util.spec_from_file_location("asd_configuration", path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def base():
    return {
        "NUM_PORTS": 1, "ADDR_WIDTH": 16, "DATA_WIDTH": 32,
        "MASTER_ID_WIDTH": 1, "NUM_MASTERS": 1, "EVENT_FIFO_DEPTH": 0,
        "REGISTER_MODE": False, "OUTPUT_ISOLATION_EN": True,
        "POLICY_PARITY_EN": True, "DFX_EN": True, "PUBLIC_ID_EN": True,
        "MGMT_MASTER_MASK": 1, "CSR_BASE": 0xEC00,
        "PORT_BASE": [0x100], "PORT_SIZE": [192],
        "RESET_PORT_CFG": [0], "RESET_PERM": [0],
    }


def test_non_power_of_two_and_exact_address_space_end():
    assert module.check(base()) == (None, [])


def test_four_byte_overflow_is_not_truncated():
    values = base()
    values["CSR_BASE"] += 4
    stage, errors = module.check(values)
    assert stage == "Elaboration"
    assert any("overflows" in error for error in errors)


def test_adjacent_regions_do_not_overlap():
    values = base()
    values.update(NUM_PORTS=2, CSR_BASE=0xE800, PORT_BASE=[0x100, 0x1C0],
                  PORT_SIZE=[192, 192], RESET_PORT_CFG=[0, 0], RESET_PERM=[0, 0])
    assert module.check(values) == (None, [])
    values["PORT_BASE"][1] -= 4
    stage, errors = module.check(values)
    assert stage == "Elaboration"
    assert any("overlap" in error for error in errors)


@pytest.mark.parametrize("name,value", [
    ("NUM_PORTS", True), ("MGMT_MASTER_MASK", 0), ("MGMT_MASTER_MASK", 2),
    ("NUM_MASTERS", 3), ("DATA_WIDTH", 64), ("RESET_PERM", [256]),
    ("RESET_PORT_CFG", [4]), ("PORT_SIZE", [True]), ("PORT_BASE", []),
])
def test_invalid_structural_inputs_fail_closed(name, value):
    values = copy.deepcopy(base())
    values[name] = value
    assert module.check(values)[0] == "Schema"


@pytest.mark.parametrize("name", ["PORT_BASE", "PORT_SIZE", "CSR_BASE", "MGMT_MASTER_MASK"])
def test_required_integration_inputs_are_not_defaulted(name):
    values = base()
    del values[name]
    assert module.check(values)[0] == "Schema"


def test_maximum_permissions_and_64_bit_management_mask():
    values = base()
    values.update(NUM_PORTS=32, ADDR_WIDTH=32, NUM_MASTERS=64, MASTER_ID_WIDTH=16,
                  MGMT_MASTER_MASK=(1 << 64) - 1, CSR_BASE=0x4000,
                  PORT_BASE=[0x100 * (p + 1) for p in range(32)],
                  PORT_SIZE=[256] * 32, RESET_PORT_CFG=[0] * 32,
                  RESET_PERM=[0] * 2048, EVENT_FIFO_DEPTH=32)
    assert module.check(values) == (None, [])
