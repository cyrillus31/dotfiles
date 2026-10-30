#!/usr/bin/env python3
"""Report Codex session identity to Herdr when launched inside a Herdr pane."""
import json
import os
import socket
import sys
import time


def main():
    if os.environ.get('HERDR_ENV') != '1':
        return
    pane = os.environ.get('HERDR_PANE_ID')
    address = os.environ.get('HERDR_SOCKET_PATH')
    if not pane or not address:
        return
    try:
        event = json.load(sys.stdin)
        if event.get('agent_id') or not event.get('session_id'):
            return
        stamp = time.time_ns()
        params = {'pane_id': pane, 'source': 'herdr:codex', 'agent': 'codex',
                  'seq': stamp, 'agent_session_id': event['session_id']}
        if event.get('transcript_path'):
            params['agent_session_path'] = event['transcript_path']
        if event.get('source'):
            params['session_start_source'] = event['source']
        request = {'id': f'herdr:codex:{stamp}', 'method': 'pane.report_agent_session', 'params': params}
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            client.settimeout(0.5)
            client.connect(address)
            client.sendall((json.dumps(request) + '\n').encode())
    except (OSError, ValueError, TypeError, AttributeError):
        # An optional status integration must never break session startup.
        return


if __name__ == '__main__':
    main()
