import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DotfilesTests(unittest.TestCase):
    def test_backup_copy_and_move_preserve_directories_and_symlinks(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            (home / '.shellrc.d').mkdir()
            (home / '.shellrc.d' / 'private.sh').write_text('private')
            (home / '.zshrc').write_text('config')
            (home / '.vimrc').symlink_to('missing')
            env = dict(os.environ, HOME=folder)
            subprocess.run(['bash', str(ROOT / 'backup.sh'), '--copy'], env=env, check=True, capture_output=True)
            self.assertTrue((home / '.zshrc').exists())
            subprocess.run(['bash', str(ROOT / 'backup.sh')], env=env, check=True, capture_output=True)
            self.assertFalse((home / '.zshrc').exists())
            backups = list(home.glob('.dotfiles-backup.*'))
            self.assertEqual(len(backups), 2)
            for backup in backups:
                self.assertEqual((backup / '.shellrc.d' / 'private.sh').read_text(), 'private')
                self.assertTrue((backup / '.vimrc').is_symlink())

    def test_shell_loader_handles_spaces_and_only_shell_files(self):
        for shell in ['bash', 'zsh']:
            with self.subTest(shell=shell), tempfile.TemporaryDirectory() as folder:
                home = Path(folder)
                scripts = home / '.shellrc.d'
                scripts.mkdir()
                (scripts / 'a script.sh').write_text('export DOTFILES_TEST_LOADED=yes\n')
                (scripts / 'ignored.txt').write_text('exit 99\n')
                (scripts / 'not-shell').symlink_to('ignored.txt')
                result = subprocess.run([shell, '-f', '-c', 'source "$1"; test "$DOTFILES_TEST_LOADED" = yes', 'test', str(ROOT / 'shell/.shellrc.sh')], env=dict(os.environ, HOME=folder), capture_output=True)
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_codex_prompt_evidence_excludes_tools_and_duplicate_records(self):
        script = ROOT / 'ai_agents/.agents/skills/ticket-log/scripts/ticket_effort.py'
        spec = importlib.util.spec_from_file_location('effort', script)
        effort = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(effort)
        records = [
            {'type': 'event_msg', 'payload': {'type': 'user_message', 'message': 'AISDLC-123 investigate'}},
            {'type': 'response_item', 'payload': {'role': 'user', 'content': 'AISDLC-123 investigate'}},
            {'type': 'event_msg', 'payload': {'type': 'agent_message', 'message': 'AISDLC-999'}},
            {'type': 'event_msg', 'payload': {'type': 'user_message', 'message': 'continue'}},
        ]
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'session.jsonl'
            path.write_text('\n'.join(json.dumps(dict(record, timestamp=f'2026-10-30T10:0{i}:00Z')) for i, record in enumerate(records)) + '\ninvalid json\n')
            evidence = effort.Evidence()
            effort.scan_codex_sessions(effort.Matcher('AISDLC', {}), evidence, folder)
            self.assertEqual(len(evidence.heartbeats['AISDLC-123']), 2)
            self.assertNotIn('AISDLC-999', evidence.heartbeats)

    def test_codex_setup_preserves_existing_settings_and_is_idempotent(self):
        import tomllib
        with tempfile.TemporaryDirectory() as folder:
            config = Path(folder) / 'config.toml'
            original = '# keep this comment\nmodel_reasoning_effort="low"\n[mcp_servers]\nexisting={url="https://example.com"}\n[tui]\nnotifications=true\n'
            config.write_text(original)
            command = ['python3', str(ROOT / 'scripts/setup-codex.py'), '--codex-home', folder]
            subprocess.run(command, check=True, capture_output=True)
            first = config.read_text()
            parsed = tomllib.loads(first)
            self.assertEqual(parsed['model_reasoning_effort'], 'low')
            self.assertTrue(parsed['tui']['notifications'])
            self.assertEqual(parsed['mcp_servers']['existing']['url'], 'https://example.com')
            self.assertIn('openaiDeveloperDocs', parsed['mcp_servers'])
            self.assertIn('# keep this comment', first)
            subprocess.run(command, check=True, capture_output=True)
            self.assertEqual(config.read_text(), first)
            self.assertEqual(len(list(Path(folder).glob('*.bak'))), 1)

    def test_mcp_import_references_environment_instead_of_copying_tokens(self):
        import tomllib
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            source = root / 'claude.json'
            subprocess.run(['python3', str(ROOT / 'scripts/setup-codex.py'), '--codex-home', str(root / 'codex')], check=True, capture_output=True)
            source.write_text(json.dumps({'mcpServers': {'gitlab': {'type': 'http', 'url': 'https://example.com/mcp', 'headers': {'Authorization': 'Bearer secret-fixture'}}}}))
            subprocess.run(['python3', str(ROOT / 'scripts/setup-codex.py'), '--codex-home', str(root / 'codex'), '--import-claude-mcp', '--claude-config', str(source)], check=True, capture_output=True)
            text = (root / 'codex/config.toml').read_text()
            self.assertNotIn('secret-fixture', text)
            self.assertEqual(tomllib.loads(text)['mcp_servers']['gitlab']['env_http_headers']['Authorization'], 'CODEX_MCP_GITLAB_AUTHORIZATION')


    def test_codex_install_keeps_runtime_local_and_installs_all_skills(self):
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder)
            subprocess.run(['make', 'codex-setup', f'STOW_TARGET={target}'], cwd=ROOT, capture_output=True, check=True)
            self.assertFalse((target / '.codex').is_symlink())
            self.assertTrue((target / '.codex/AGENTS.md').is_symlink())
            self.assertEqual(len(list((target / '.agents/skills').glob('*/SKILL.md'))), 24)
            self.assertTrue((target / '.codex/config.toml').is_file())
            self.assertFalse((target / '.codex/config.toml.example').exists())
            self.assertFalse((target / 'README.md').exists())

    def test_reconcile_unlinks_old_profile_and_preserves_unrelated_files(self):
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder) / 'home'
            target.mkdir()
            state = Path(folder) / 'profile'
            subprocess.run(['make', 'macbook', f'STOW_TARGET={target}', f'CURRENT_PROFILE={state}'], cwd=ROOT, capture_output=True, check=True)
            (target / 'unrelated').write_text('keep')
            self.assertTrue((target / '.aerospace.toml').exists())
            subprocess.run(['make', 'reconcile', 'PROFILE=common', f'STOW_TARGET={target}', f'CURRENT_PROFILE={state}'], cwd=ROOT, capture_output=True, check=True)
            self.assertFalse((target / '.aerospace.toml').exists())
            self.assertTrue((target / '.shellrc.sh').exists())
            self.assertEqual((target / 'unrelated').read_text(), 'keep')
            self.assertEqual(state.read_text(), 'common\n')

    def test_cancelled_theme_selection_does_not_replace_active_theme(self):
        import shutil
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            shutil.copy(ROOT / 'starship/.config/starship-switcher.sh', root / 'switch.sh')
            (root / 'starship-themes').mkdir()
            (root / 'starship-themes/theme.toml').write_text('format="test"')
            (root / 'starship.toml').write_text('keep')
            (root / 'fzf').write_text('#!/bin/sh\nexit 130\n')
            (root / 'fzf').chmod(0o755)
            result = subprocess.run(['bash', str(root / 'switch.sh')], env=dict(os.environ, PATH=str(root) + os.pathsep + os.environ['PATH']), capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((root / 'starship.toml').read_text(), 'keep')


    def test_dry_run_leaves_profile_and_target_unchanged(self):
        with tempfile.TemporaryDirectory() as folder:
            state = Path(folder) / 'profile'
            state.write_text('fedora\n')
            target = Path(folder) / 'home'
            target.mkdir()
            subprocess.run(['make', 'dry-run', 'PROFILE=common', f'STOW_TARGET={target}', f'CURRENT_PROFILE={state}'], cwd=ROOT, capture_output=True, check=True)
            self.assertEqual(state.read_text(), 'fedora\n')
            self.assertEqual(list(target.iterdir()), [])


if __name__ == '__main__':
    unittest.main()
