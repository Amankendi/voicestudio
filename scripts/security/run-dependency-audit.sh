#!/usr/bin/env bash
# Advisory requests contain dependency metadata, not application source/secrets.
set -euo pipefail
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT
set +e
if [ -f pnpm-lock.yaml ]; then
  XDG_DATA_HOME="$task_dir/data" npx --yes --cache "$task_dir/cache" pnpm@10.15.0 \
    --config.manage-package-manager-versions=false audit --audit-level=high --json \
    > "$task_dir/result.json" 2> "$task_dir/log"
  scan_status=$?
elif [ -f package-lock.json ]; then
  NPM_CONFIG_CACHE="$task_dir/cache" npm audit --package-lock-only --audit-level=high --json \
    > "$task_dir/result.json" 2> "$task_dir/log"
  scan_status=$?
else
  echo '{"check":"dependency-audit","status":"NOT VERIFIED","reason":"No supported lockfile"}'
  exit 2
fi
set -e
python3 - "$task_dir/result.json" "$scan_status" <<'PY'
import json,pathlib,sys
try: data=json.loads(pathlib.Path(sys.argv[1]).read_text())
except (ValueError,OSError): data={}
counts=data.get('metadata',{}).get('vulnerabilities')
if not isinstance(counts,dict) or data.get('error'):
    print(json.dumps({'check':'dependency-audit','status':'NOT VERIFIED','reason':'Advisory service or audit unavailable'}))
    sys.exit(2)
high=counts.get('high',0)+counts.get('critical',0)
print(json.dumps({'check':'dependency-audit','status':'FAIL' if high else 'PASS',
                  'scope':'high and critical advisory gate','vulnerabilities':counts}))
sys.exit(1 if high else 0)
PY
