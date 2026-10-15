#!/usr/bin/env bash
# No secret-bearing artifacts, comments, telemetry, or production access.
set -euo pipefail
if [ "$(git rev-parse --is-shallow-repository)" != false ]; then
  echo 'BLOCKED: full Git history is required (fetch-depth: 0).'
  exit 2
fi
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT
binary=${GITLEAKS_BINARY:-}
if [ -z "$binary" ]; then
  archive="$task_dir/gitleaks.tar.gz"
  curl --fail --silent --show-error --location --retry 2 \
    https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz \
    --output "$archive"
  printf '%s  %s\n' '551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb' "$archive" | sha256sum --check --status
  tar --extract --gzip --file "$archive" --directory "$task_dir" --no-same-owner gitleaks
  binary="$task_dir/gitleaks"
fi
if [ "$("$binary" version)" != '8.30.1' ]; then
  echo 'BLOCKED: expected the reviewed Gitleaks version.'
  exit 2
fi
printf '[extend]\nuseDefault = true\n' > "$task_dir/config.toml"
ignore_file="$PWD/scripts/security/gitleaks-ignore.txt"
[ -f "$ignore_file" ] || ignore_file=/dev/null
set +e
"$binary" git . --log-opts=--all --redact=100 --no-banner --log-level=error \
  --ignore-gitleaks-allow --gitleaks-ignore-path "$ignore_file" \
  --config "$task_dir/config.toml" --report-format=json \
  --report-path "$task_dir/findings.json" > "$task_dir/tool.log" 2>&1
scan_status=$?
set -e
python3 - "$task_dir/findings.json" "$scan_status" <<'PY'
import json, pathlib, sys
p=pathlib.Path(sys.argv[1]); code=int(sys.argv[2])
rows=json.loads(p.read_text()) if p.exists() else []
safe=[{'rule':r.get('RuleID'),'file':r.get('File'),'line':r.get('StartLine'),
       'commit':r.get('Commit')} for r in rows]
print(json.dumps({'check':'gitleaks-history','version':'8.30.1','exit_code':code,
                  'status':'PASS' if code==0 else 'FAIL' if code==1 else 'NOT VERIFIED',
                  'candidate_count':len(rows),'candidates':safe}))
PY
exit "$scan_status"
