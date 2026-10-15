#!/usr/bin/env bash
# Local rules, no source uploads, metrics disabled. Output omits matched source.
set -euo pipefail
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT
export SEMGREP_SETTINGS_FILE="$task_dir/settings.yml"
export SEMGREP_LOG_FILE="$task_dir/semgrep.log"
set +e
SEMGREP_SEND_METRICS=off semgrep scan --config scripts/security/semgrep.yml \
  --metrics=off --disable-version-check --jobs=2 --max-memory=512 --timeout=5 --error --quiet --json \
  > "$task_dir/result.json" 2> "$task_dir/log"
scan_status=$?
set -e
python3 - "$task_dir/result.json" "$scan_status" <<'PY'
import json,pathlib,sys
try:
    data=json.loads(pathlib.Path(sys.argv[1]).read_text())
except (ValueError,OSError):
    print(json.dumps({'check':'semgrep-local-rules','status':'NOT VERIFIED','exit_code':int(sys.argv[2])}))
    sys.exit(2)
findings=[{'rule':r['check_id'],'file':r['path'],'line':r['start']['line']} for r in data.get('results',[])]
code=int(sys.argv[2])
if data.get('errors') and code==0:
    code=2
print(json.dumps({'check':'semgrep-local-rules','exit_code':int(sys.argv[2]),
                  'status':'PASS' if code==0 else 'FAIL' if code==1 else 'NOT VERIFIED',
                  'candidate_count':len(findings),'candidates':findings,
                  'error_count':len(data.get('errors',[]))}))
if code==2:
    sys.exit(2)
PY
exit "$scan_status"
