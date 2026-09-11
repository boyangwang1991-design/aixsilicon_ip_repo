"""Compare elaborated SystemRDL structure against the immutable GPIO contract."""
from pathlib import Path
import hashlib
import json
import re

from systemrdl import RDLCompiler
from systemrdl.node import RegNode


def main():
    root = Path(__file__).resolve().parents[1]
    source = root / "regs/gpio.rdl"
    compiler = RDLCompiler()
    compiler.compile_file(str(source))
    top = compiler.elaborate().top
    actual = {}
    fields = []
    for reg in top.descendants(unroll=True):
        if not isinstance(reg, RegNode):
            continue
        actual[reg.absolute_address] = reg.inst_name
        for field in reg.fields():
            fields.append(re.sub(r"\[\d+\]", "[]", field.get_path()))
    contract = (root / "gpio_contract.md").read_text()
    expected = {}
    groups = [("15.2", [0]), ("15.3", [0x100 + 0x100*b for b in range(4)]),
              ("15.4", [0x1000 + 0x20*i for i in range(128)]),
              ("15.5", [0x3000 + 0x100*b for b in range(4)])]
    for section, bases in groups:
        body = contract.split("### " + section, 1)[1].split("\n##", 1)[0]
        for line in body.splitlines():
            if not line.startswith("| 0x"):
                continue
            _, offsets, names, *_ = [part.strip() for part in line.split("|")]
            if "～" in offsets:
                lo, hi = [int(v, 16) for v in offsets.split("～")]
                addresses = list(range(lo, hi+1, 4))
                regnames = ["EVENT_HEAD"+str(i) for i in range(len(addresses))]
            else:
                addresses = [int(v,16) for v in offsets.split("/")]
                if len(addresses) > 1:
                    prefix = names.split("0/")[0]
                    regnames = [prefix + str(i) for i in range(len(addresses))]
                else:
                    regnames = [names]
            for base in bases:
                for offset, name in zip(addresses, regnames, strict=True):
                    expected[base+offset] = name
    behavior = "\n".join(p.read_text() for p in (root/"docs/lld").glob("*.md"))
    references = re.findall(r"^register_ref: (.+)$", behavior, re.M)
    errors = []
    for address in sorted(set(expected)|set(actual)):
        if expected.get(address) != actual.get(address):
            errors.append(f"0x{address:04x}: contract={expected.get(address)}, RDL={actual.get(address)}")
    if set(fields) != set(references):
        errors.append(f"field behavior mismatch: missing={sorted(set(fields)-set(references))}; extra={sorted(set(references)-set(fields))}")
    result = {"scope": "contract address/name map and field behavior reference completeness; no RTL functional proof",
              "register_instances": len(actual), "field_templates": len(set(fields)), "errors": errors,
              "sources": {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in [source, root/"gpio_contract.md"]}}
    output = root / "reports/registers/contract_structure.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, ensure_ascii=False, indent=2)+"\n")
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return bool(errors)


if __name__ == "__main__":
    raise SystemExit(main())
