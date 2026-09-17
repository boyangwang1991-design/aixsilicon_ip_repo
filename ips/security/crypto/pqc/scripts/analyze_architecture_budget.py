#!/usr/bin/env python3
"""Read-only structural bound; not a simulation or physical PPA signoff.
Run from the IP workspace through the workflow root uv environment.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import yaml


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--output', type=Path, default=Path('build/design/hld_resume/architecture_budget.json'))
    args = parser.parse_args()
    root = args.workspace.resolve()
    output = (root / args.output).resolve()
    if (root / 'build').resolve() not in output.parents:
        parser.error('output must be under workspace build/')
    rtl = root / 'rtl/pqc_keccak.sv'
    rates = {name: int(rate) for name, rate in re.findall(
        r'KEC_(SHA3_256|SHA3_512|SHAKE128|SHAKE256):\s*begin\s+rate_bytes\s*=\s*10\x27d(\d+)',
        rtl.read_text())}
    if set(rates) != {'SHA3_256', 'SHA3_512', 'SHAKE128', 'SHAKE256'}:
        raise ValueError('cannot establish all four rate constants from current RTL')
    model_path = root / 'model/parameter_space.yaml'
    model = yaml.safe_load(model_path.read_text())
    defaults = {p['name']: p['default'] for p in model['parameters']}
    rows = []
    for cfg in model['configurations']:
        values = dict(defaults, **cfg['values'])
        rounds = values['KECCAK_ROUNDS_PER_CYCLE']
        perm_cycles = math.ceil(24 / rounds)
        peak_dma = values['DMA_DATA_WIDTH'] / 8
        for function, rate in sorted(rates.items()):
            ideal = rate / perm_cycles
            rows.append(dict(config=cfg['id'], function=function,
                             security_levels=[0, 1],
                             rate_bytes=rate, permutation_cycles=perm_cycles,
                             peak_dma_bytes_per_cycle=peak_dma,
                             legacy_half_peak_dma_bytes_per_cycle=peak_dma / 2,
                             target_cycles_per_block=math.ceil(rate / 8) + perm_cycles + 2,
                             target_bytes_per_cycle=rate / (math.ceil(rate / 8) + perm_cycles + 2),
                             ideal_single_context_bytes_per_cycle=ideal,
                             current_byte_port_upper_bound=min(1.0, ideal),
                             current_byte_port_meets_target=min(1.0, ideal) >= rate / (math.ceil(rate / 8) + perm_cycles + 2),
                             legacy_raw_peak_target_impossible=ideal < peak_dma / 2))
    # Candidate HPC3+ architecture only: these are lower bounds, not RTL evidence.
    # Three fresh bits per first-order HPC3+ bit-AND; chi has 1600 per round.
    entropy_port_bits = 64
    chi_bits_per_round = 3 * 1600
    chi_bits_per_permutation = 24 * chi_bits_per_round
    level2 = dict(
        status='candidate_not_implemented', shares=2,
        scheme='Boolean HPC3+ and arithmetic sharing; conversions require verification',
        entropy_port_bits=entropy_port_bits,
        chi_fresh_bits_per_round=chi_bits_per_round,
        chi_fresh_bits_per_permutation=chi_bits_per_permutation,
        continuous_entropy_cycles_lower_bound=math.ceil(chi_bits_per_permutation / entropy_port_bits),
        excludes=['initial sharing', 'refresh', 'conversions', 'samplers', 'entropy stalls'],
        memory=[dict(logical_sram_kib=k, physical_data_sram_kib=2*k,
                     physical_key_data_kib=16, total_physical_data_kib=2*k+16)
                for k in (32, 64, 96)],
        memory_excludes=['ECC', 'tags', 'valid bits', 'random buffers', 'gadget registers'],
        capacity_schedule_verified=False,
        original_hash_cycle_contract_compatible=False,
        round_random_collection_cycles=math.ceil(chi_bits_per_round / entropy_port_bits),
        round_compute_budget_cycles=4,
        permutation_budget_cycles=24 * (math.ceil(chi_bits_per_round / entropy_port_bits) + 4),
        initial_sharing_budget_cycles=26,
        random_buffer_bytes=chi_bits_per_round // 8,
        hash_rows=[dict(function=name, rate_bytes=rate,
                       target_cycles_per_block=math.ceil(rate/8)+1896+2,
                       target_bytes_per_cycle=rate/(math.ceil(rate/8)+1896+2))
                   for name, rate in sorted(rates.items())],
    )
    inputs = [rtl, model_path, Path(__file__).resolve(), root / 'docs/lrs/05_performance.md', root / 'docs/hld/08_performance.md', root / 'docs/hld/09_masking_level2.md']
    data = dict(kind='rtl-structural-upper-bound/1.0', measured_ppa=False,
                assumptions=['One sequential Keccak sponge context for one message.',
                             'Level 0/1: 24 rounds per permutation, 1 or 2 rounds per cycle.',
                             'Best possible bound ignores absorb, padding, arbitration and all stalls.',
                             'Level 0/1 contract: ceil(R/8)+24/r+2 cycles per full block.',
                             'Level 2 candidate: ceil(R/8)+1896+2; continuous 64-bit random input; no random/compute overlap.'],
                sources={str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs},
                rows=rows, level2_candidate=level2)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(data, indent=2) + '\n')
    print('Structural bounds written:', output)
    for row in rows:
        if row['function'] == 'SHAKE256':
            print(row['config'], 'ideal=', round(row['ideal_single_context_bytes_per_cycle'], 3),
                  'half_peak=', row['legacy_half_peak_dma_bytes_per_cycle'],
                  'legacy_raw_peak_target_impossible=', row['legacy_raw_peak_target_impossible'])


if __name__ == '__main__':
    main()
