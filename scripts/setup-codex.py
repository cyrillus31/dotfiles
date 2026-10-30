#!/usr/bin/env python3
"""Add Codex defaults without replacing existing config, auth, or trust settings."""
import argparse
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import tempfile
import tomllib
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]


def literal(value):
    if isinstance(value, dict):
        return '{ ' + ', '.join(json.dumps(k) + ' = ' + literal(v) for k, v in value.items()) + ' }'
    if isinstance(value, list):
        return "[" + ", ".join(literal(item) for item in value) + "]"
    return json.dumps(value, ensure_ascii=False)


def missing_config(original, defaults):
    """Preserve original text/comments; append only absent values or table subtrees."""
    parsed = tomllib.loads(original)
    insertions = {0: []}
    tables = {}
    offset = 0
    for line in original.splitlines(keepends=True):
        offset += len(line)
        if line.lstrip().startswith('[') and not line.lstrip().startswith('[['):
            try:
                table = tomllib.loads(line)
            except tomllib.TOMLDecodeError:
                continue
            path = ()
            while isinstance(table, dict) and len(table) == 1:
                key, table = next(iter(table.items()))
                path += (key,)
            tables[path] = offset

    def visit(values, existing, path=()):
        for key, value in values.items():
            if key in existing:
                if isinstance(value, dict) and isinstance(existing[key], dict):
                    visit(value, existing[key], (*path, key))
                continue
            if isinstance(value, dict):
                visit(value, {}, (*path, key))
                continue
            full_path = (*path, key)
            parents = [parent for parent in tables if full_path[:len(parent)] == parent]
            parent = max(parents, key=len) if parents else ()
            position = tables[parent] if parent else 0
            assignment = '.'.join(json.dumps(part) for part in full_path[len(parent):]) + ' = ' + literal(value)
            insertions.setdefault(position, []).append(assignment)

    visit(defaults, parsed)
    merged = original
    for position in sorted(insertions, reverse=True):
        if insertions[position]:
            merged = merged[:position] + '\n'.join(insertions[position]) + '\n' + merged[position:]

    tomllib.loads(merged)  # Reject unsupported table shapes before writing anything.
    return merged


def import_http_servers(path):
    servers = {}
    if not path.exists():
        print('No local Claude MCP configuration found.')
        return servers
    source = json.loads(path.read_text()).get('mcpServers', {})
    for name, settings in source.items():
        if settings.get('type') != 'http' or not settings.get('url'):
            print(f'Skipping non-HTTP MCP server: {name}')
            continue
        url = settings['url']
        parts = urlsplit(url)
        if parts.scheme not in ('http', 'https') or parts.username or parts.password or parts.query or parts.fragment:
            print(f'Skipping MCP server with unsupported URL or embedded credentials: {name}')
            continue
        server = {'url': url}
        for header in settings.get('headers', {}):
            variable = 'CODEX_MCP_' + re.sub('[^A-Z0-9]', '_', name.upper() + '_' + header.upper())
            server.setdefault('env_http_headers', {})[header] = variable
            print(f'{name}: export {variable} with the full {header} value locally; no credential was copied.')
        servers[name] = server
    return servers


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--codex-home', type=Path, default=Path(os.environ.get('CODEX_HOME', Path.home() / '.codex')))
    parser.add_argument('--claude-config', type=Path, default=Path.home() / '.claude.json')
    parser.add_argument('--import-claude-mcp', action='store_true')
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    defaults = tomllib.loads((ROOT / 'ai_agents/.codex/config.toml.example').read_text())
    hook = args.codex_home.resolve() / 'hooks/herdr-session.py'
    if hook.exists():
        defaults['hooks'] = {'SessionStart': [{'hooks': [{'type': 'command', 'command': 'python3 ' + shlex.quote(str(hook)), 'timeout': 10}]}]}
    if args.import_claude_mcp:
        defaults['mcp_servers'].update(import_http_servers(args.claude_config))
    config = args.codex_home / 'config.toml'
    original = config.read_text() if config.exists() else ''
    merged = missing_config(original, defaults)
    if merged == original:
        print('Codex configuration already contains these settings; existing values preserved.')
        return
    if args.dry_run:
        print('Codex configuration would gain missing defaults; no files changed.')
        return
    args.codex_home.mkdir(parents=True, exist_ok=True)
    # Keep a unique backup and update a local symlink target rather than replacing the link.
    destination = config.resolve()
    if config.exists():
        descriptor, backup = tempfile.mkstemp(prefix='config.toml.', suffix='.bak', dir=args.codex_home)
        os.close(descriptor)
        shutil.copy2(config, backup)
    descriptor, temporary = tempfile.mkstemp(prefix='.config.', dir=destination.parent)
    try:
        with os.fdopen(descriptor, 'w') as handle:
            handle.write(merged)
        os.replace(temporary, destination)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    print('Added missing Codex settings. Existing values, authentication, and trust entries preserved.')


if __name__ == '__main__':
    main()
