#!/usr/bin/env python3
"""Freeze a complete source tree for reproducible EDA amid concurrent editing.

Run from the workflow uv environment. No existing evidence is relabelled. The
original source and all tutorial files remain untouched; only build/ is written.
"""
from pathlib import Path
import hashlib
import json
import os
import shutil
import tempfile

IP = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    (IP / 'build').mkdir(exist_ok=True)
    (IP / 'build/FUSESOC_IGNORE').touch()
    files = []
    for directory, children, names in os.walk(IP):
        children[:] = [n for n in children if n not in
                       {'build', '.git', '__pycache__', '.venv'}]
        files.extend(Path(directory) / n for n in names
                     if not n.endswith('.pyc') and (Path(directory) / n).is_file())
    files.sort()
    before = {str(p.relative_to(IP)): digest(p) for p in files}
    parent = IP / 'build/frozen'
    parent.mkdir(parents=True, exist_ok=True)
    run = Path(tempfile.mkdtemp(prefix='source-', dir=parent))
    # Preserve the IP basename used by stage report generators.
    source = run / IP.name
    source.mkdir()
    for name, expected in before.items():
        target = source / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(IP / name, target)
        if digest(target) != expected:
            raise RuntimeError(f'input changed while copying: {name}; snapshot is not usable')
    # Each runner independently freezes and rechecks its full copied inputs.
    manifest = dict(schema='pqc-source-snapshot/1', origin=str(IP), source=str(source),
                    files=before, copied_files_verified=True)
    (run / 'source_manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(source)


if __name__ == '__main__':
    main()
