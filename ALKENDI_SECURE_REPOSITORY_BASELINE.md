# ALKENDI Secure Repository Baseline

Version: 1.0 · Owner: ALKENDI LAB · Technical reviewer: Umayr · 2026-10-15

Canonical governance source: `Amankendi/Amankendi`. This reusable standard extends
the [AMAN Product Build Standard](https://github.com/Amankendi/Amankendi/blob/main/docs/00_AMAN_PRODUCT_BUILD_STANDARD.md)
and [ALKENDI Work System](https://github.com/Amankendi/Amankendi/blob/main/docs/01_ALKENDI_WORK_SYSTEM.md).
It preserves each project's approved Product Baseline. Adoption in a PR is a
proposal until independently reviewed and merged by the owner.

## Evidence and acceptance

Use only these control results:

| Result | Meaning |
| --- | --- |
| PASS | The stated scope is supported by dated, reproducible evidence. |
| FAIL | A specific weakness was confirmed. |
| BLOCKED | A named permission, owner decision or credential is required. |
| NOT VERIFIED | Available evidence does not establish the result. |

Every result records repository, exact commit SHA, environment, UTC timestamp,
command/API or CI URL, scope, reviewer, limitations and next action. Distinguish
code proposed, code merged, configuration applied, deployed, and runtime verified.
Private visibility and successful CI alone do not establish security. A scanner
match is a candidate until triaged; a clean scan is limited to its rules and scope.
Never claim complete protection. Never publish secret values, matched source,
tokens, private customer data or unredacted scanner artifacts.

## 1. Least Privilege

- Inventory owner, visibility, collaborators, roles, installed Apps, deploy keys,
  service identities and CI token defaults. Reconcile each grant to an owner,
  purpose, repository scope, minimum capability and review/expiry date.
- Use read-only checkout credentials, `persist-credentials: false`, and explicit
  workflow permissions. Grant write/OIDC only to the job that needs it.
- Keep products' auth, databases, storage, secrets and deployment authority
  separate unless an approved shared-resource declaration defines the boundary.
- Enforce authorization on servers and data stores. Test anonymous, non-member,
  viewer, member, admin, suspended, revoked, and cross-tenant access independently.
- RLS does not govern TRUNCATE. Review table grants, function EXECUTE, views and
  SECURITY DEFINER search paths as well as RLS. Never use editable user metadata
  as authority. Service-role keys stay server-side.
- Evidence: sanitized grants/roles and negative authorization tests. Permission
  changes and production privilege corrections require explicit owner approval.

## 2. Mandatory CI Checks

- On every PR and default-branch commit, require reproducible install, applicable
  lint/typecheck, meaningful tests, build, secret scanning and dependency review.
  Data authorization changes require isolated SQL and cross-user negative tests.
- Assign stable check names; require their successful results for the exact head
  commit. Include web typechecking explicitly when a monorepo root omits it.
- Run PR code without production secrets or production writes. Pin Actions to
  reviewed full commit SHAs and binary tools to a version plus checksum.
- Do not interpolate untrusted PR/issue text into shell code. Do not execute PR
  code under `pull_request_target` or a privileged `workflow_run` context.
- The supplied `ALKENDI Security / secrets` job scans fetched Git history with
  Gitleaks 8.30.1 and redacted output. The companion SAST job uses Semgrep 1.181.0 with three local rules for eval, Python shell execution and disabled TLS verification. These checks are limited detectors, not a complete SAST suite.
  Inline ignores are disabled; exceptions require exact fingerprints and review.
- Evidence: workflow diff, exact check/run URLs, test totals and a regression that
  fails before a security fix and passes after it. Skips are not passes.

## 3. Protected Main Branch

- Protect `main`, or the actual production/default branch when named `master`.
  Require PRs, at least one independent approval, stale-review dismissal, resolved
  conversations and the project's required checks. Apply to administrators, audit
  bypass actors, and block force pushes and deletion.
- Security-critical work requires independent review of the exact tested commit.
  A second comment from the same account or the implementing agent is not proof
  of independence. Keep reviewer identity and review artifact in the work record.
- Evidence: branch `protected` flag, active rules/protection settings, approvals,
  required checks and bypass list. An inaccessible admin endpoint is BLOCKED.
- Do not silently buy a plan. If enforcement is unavailable on a private free
  repository, retain privacy, restrict release credentials, freeze direct-main
  operational changes and use two-person signed review/release records until the
  owner selects a supported enforcement arrangement. This fallback is procedural
  and must remain FAIL/BLOCKED for automated branch enforcement.

## 4. Secret Management

- Track only sanitized `.env.example`/sample/template files. Ignore real dotenv
  files, local credentials, private keys, deployment state and backup bundles.
- Keep production and preview secrets separate. Record credential owner, scope,
  expiry and last review when available; never retrieve values for an audit.
- Scan current code and all fetched branches/tags/history. Record missing refs,
  LFS/submodule/archive limitations and scanner configuration. Exact false-positive
  exceptions must state a reason and never hide a whole file or key family.
- A Firebase/browser publishable identifier needs API/app restrictions and data
  rules verification; its presence alone does not prove compromise.
- Suspected exposure: preserve redacted evidence and notify the owner privately.
  Owner-approved rotation/revocation precedes any separately approved history
  rewrite. Removing the current value alone does not revoke it.

## 5. Dependency Security

- Commit a lockfile, pin the package manager, use frozen/clean installs and review
  install scripts. Review npm/pnpm, Python, Rust and Actions dependencies as used.
- Use weekly Dependabot PRs where supported, with no auto-merge. A configuration
  file does not prove server-side alerts are enabled.
- Record advisory IDs, affected locked versions, severity, exposure and fixed
  versions. Apply compatible updates on isolated branches; validate all consumers.
  Do not run a force upgrade to make an audit counter disappear.
- Block release on unresolved critical/high findings without an explicit, dated
  owner risk decision and compensating controls.
- Free alternatives: local `npm audit`/`pnpm audit`, `pip-audit`, `cargo audit`,
  Gitleaks and Semgrep Community with local rules and metrics disabled. Report
  each actual run; recommending a tool is not evidence that it ran.

## 6. Secure Deployment

- Keep staging/preview separate from production. Require reviewed SHA, green CI,
  protected environment approval and branch restrictions before production jobs.
  Manual dispatch alone is not an approval or proof that the selected ref is safe.
- Scope host credentials to the exact project and environment. Validate callback
  allowlists, auth, admin routes, tenant isolation and fail-closed cost limits.
- Do not run deployments, secret sync, DNS edits, paid upgrades or migrations as
  incidental audit actions. Vercel account blocks need account-owner resolution;
  do not bypass checks or mislabel an old READY deployment as current code.
- Cloudflare custom domains and workers.dev/preview exposure require explicit
  review. Supabase privileged grants need staging proof and separate rollout.
- Evidence: deployed commit, target, build checks, approved host, smoke tests,
  rollback artifact and independent approval. Source-only checks are insufficient.

## 7. Audit Logging

- Record actor, operation, repository/project, UTC time, correlation/work ID,
  approved SHA, decision, outcome and sanitized provider/CI evidence.
- Log sensitive configuration changes and grant/revocation events. Restrict log
  access and retention. Never log authorization headers, credentials or email bodies.
- Keep GitHub review/issue evidence durable; do not use chat memory as the sole
  approval record. Record unavailable account audit logs as BLOCKED/NOT VERIFIED.

## 8. Backup & Recovery

- Maintain an encrypted owner-controlled off-device mirror/bundle of all approved
  refs; record checksums, access controls, retention, RPO and RTO. Baseline targets:
  code RPO 24 hours and code RTO 4 hours, subject to owner acceptance and a drill.
- Include LFS objects, submodule sources, releases and configuration inventories
  separately. Code bundles do not back up databases, issues, secrets or host state.
- Run `git fsck --full`, create a bundle, verify it, restore into an isolated path
  and compare every ref. Never test restore by overwriting production or main.
- Workspace mirrors prove local code recovery only; they are not durable offsite
  backups. Owner storage, encryption and retention evidence remain required.

## 9. Incident Response

- Notify the owner and Umayr privately with severity, scope, UTC discovery time,
  affected object IDs and redacted evidence. Stop unsafe affected operations.
- Preserve logs/history; do not delete repositories, branches or evidence.
- Propose containment, scoped credential rotation, remediation, independent tests,
  controlled recovery and a post-incident review. Owner approval gates production
  mutations. Never validate a candidate key by using it against a paid/live API.

## 10. Periodic Security Review

- Weekly: dependencies, failed security checks and unresolved critical/high risks.
- Monthly: collaborators, Apps, keys, token scope/expiry, workflow privileges,
  bypass actors, protected branches and environment approval rules.
- Quarterly: independent cross-tenant/admin tests, restore drill, incident exercise
  and baseline drift review. Repeat after material auth, deployment or data changes.
- A schedule in this document is a policy requirement, not an activated automation.
  Record named owner, due date, evidence, exceptions and expiry for each review.

## AMAN / APLC execution record

Use the existing documented lifecycle without restarting product planning:

`INTAKE → BOUNDARY_CHECK → STAGE_1 → CLAUDE_REVIEW → IMPLEMENTATION → CHATGPT_ACCEPTANCE → INTEGRATION_CHECK → VERIFIED`

For this owner-assigned Codex implementation, Umayr supplies independent technical
review before acceptance. Map each APLC work item to these existing stages; this
baseline does not invent a second product lifecycle or change release authority.

Every PR records `WORK_ID`, `PROJECT_ID`, `TARGET_REPOSITORY`, `DONE`, `TESTED`,
`FAILED`, `BLOCKED`, `SECURITY / PRIVACY IMPACT`, `CROSS-PROJECT DEPENDENCIES`,
`COST / TOKEN IMPACT`, `MIGRATIONS / API IMPACT`, `ROLLBACK` and `NEXT`.
Owner-only actions include access/visibility changes, deletion, production key
rotation, DNS/hosting changes, merge and deployment. No paid upgrade is authorized.
