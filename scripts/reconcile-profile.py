#!/usr/bin/env python3
"""Opt-in profile switching; normal make profile targets remain additive."""
import subprocess
import sys
from pathlib import Path


def packages(profile, variables):
    if profile not in variables:
        raise ValueError(f'Unknown profile: {profile}')
    return [package for name in variables[profile] for package in
            (packages(name, variables) if name in variables else [name])]


def main():
    dry_run = "--dry-run" in sys.argv
    arguments = [arg for arg in sys.argv[1:] if arg != "--dry-run"]
    profile, target, state = arguments
    variables = {}
    for line in Path('Makefile').read_text().splitlines():
        if '_TARGETS :=' in line:
            name, value = line.split(':=', 1)
            variables[name.strip().removesuffix('_TARGETS').lower()] = value.split()
    try:
        desired = packages(profile, variables)
        previous = Path(state).read_text().strip() if Path(state).exists() else profile
        obsolete = sorted(set(packages(previous, variables)) - set(desired))
    except ValueError as error:
        sys.exit(str(error))
    command = ['stow', '--target=' + target, '--ignore=(^|/)(README[^/]*|\\.DS_Store|[^/]*\\.example)$']
    if obsolete and not dry_run:
        command += ['-D', *obsolete]
    command += ['-R', *desired]
    subprocess.run([*command, '--simulate'], check=True)
    if dry_run:
        return
    (Path(target) / ".codex").mkdir(parents=True, exist_ok=True)
    subprocess.run(command, check=True)
    Path(state).write_text(profile + '\n')


if __name__ == '__main__':
    main()
