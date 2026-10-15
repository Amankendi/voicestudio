#!/usr/bin/env python3
"""Fail on tracked private dotenv files. Never read or print their contents."""
import json
from pathlib import PurePosixPath
import subprocess
import sys

def forbidden(path):
    name = PurePosixPath(path).name
    if name != '.env' and not name.startswith('.env.'):
        return False
    allowed = {'.env.example', '.env.sample', '.env.template'}
    return name not in allowed and not name.endswith(('.example', '.sample', '.template'))

def main():
    result = subprocess.run(['git', 'ls-files', '-z'], capture_output=True, check=True)
    paths = result.stdout.decode('utf-8', errors='replace').split('\0')
    found = [p for p in paths if p and forbidden(p)]
    print(json.dumps({'check': 'tracked-dotenv', 'status': 'FAIL' if found else 'PASS',
                      'paths': found, 'tracked_files': len([p for p in paths if p])}))
    return bool(found)

if __name__ == '__main__':
    sys.exit(main())
