# Deployment Safety Checklist

Read this file before any mutating release operation and before reporting
deployment, repair, reset, upgrade, local runtime, or MCP completion.

## Pre-Mutation Checklist

All items must be true before a mutating step:

- Current `SKILL.md` version satisfies release `min_skill_version`.
- Release manifest was fetched from the public URL or verified authenticated
  GitHub/local checkout.
- Release repository ref and manifest release version are recorded.
- Requested operation exists in the manifest.
- Selected Agent runtime is supported by `runtime_support`.
- AWS account readiness is confirmed for cloud provisioning.
- Region, domain, instance plan, and paid-resource consent are confirmed when
  cloud resources are used.
- Clean reset is confirmed as existing-node reset only; it does not authorize
  instance deletion, new instance creation, static IP allocation, or DNS changes.
- Data retention choice is explicit for repair, reset, restore, and rollback.
- Script path and arguments come from manifest operation keys.
- No standalone CLI, remembered command, stale local checkout, or synthetic
  state file is being used.
- No secret values are printed, pasted, logged, or placed in user handoff.

If any item is false, stop and report the missing gate.

## Stage Checks

Remote node:

- backend image is manifest-declared and anonymously pullable unless manifest
  declares registry login
- Public DNS target matches the expected static IP; if only the local resolver
  returns a reserved/proxy IP such as `198.18.0.7`, record the release DNS
  diagnostic and treat it as a local machine resolver issue
- Caddy/TLS uses the release HTTPS template
- public health and well-known checks pass

Runtime secret sync:

- Gateway token file and Agent token file are freshly synced from the current
  backend
- bootstrap credentials, Admin access token, Portal password, Gateway token,
  and Agent token files are freshly synced from current backend evidence
- legacy Channel/MCP env names are not primary contract values

App handoff:

- HTTPS handoff verification passed
- setup code comes from release-generated setup-code file
- code is current, unexpired, and 8 lowercase letters/digits
- no Portal password, Admin access token, Gateway token, Agent token, bootstrap
  credential, or setup page value is exposed

Connector or Bridge:

- native plugin or Bridge provider is release-declared for the selected runtime
- required runtime restart/reload/service start completed
- backend Agent status is online when Bridge is used
- App-to-Agent message round trip succeeds

MCP:

- runtime MCP server list contains `p2p-im`
- runtime can start the release-declared MCP launcher
- required tools are discoverable
- discovery is recorded through the release-declared recorder

## Failure Handling

| Trigger | Required action |
|---|---|
| Manifest fetch fails | Stop; use authenticated GitHub/local verified checkout only if available. |
| Local release is stale | Stop; update release checkout before mutation. |
| Script fails | Stop at that stage; report operation key, sub-stage, endpoint, and log source. |
| SSH repeatedly closes | Summarize retry evidence; do not blame VPS/network from one failure or one `ssh echo OK`. |
| Public DNS resolves to reserved/proxy/unexpected IP | Block App handoff and report expected static IP. |
| Public DNS is correct but local resolver returns reserved/proxy IP | Continue only through release verifier DNS diagnostics; tell the user to add a temporary `/etc/hosts` entry or stop the local DNS proxy for manual local tests. |
| Backend image is private and no registry login step exists | Stop before remote bootstrap. |
| SSH key missing during clean reset | Stop; do not replace the node from clean-reset confirmation. Ask for key recovery or a separate node replacement confirmation. |
| State file is missing or inconsistent | Reconstruct through release-declared status/plan/bootstrap/repair/reset, not synthetic state. |
| Setup-code generation returns 401/403 | Treat as stale or mismatched Admin access token evidence; rerun release-declared bootstrap/runtime sync path. |
| Setup-code generation returns 429 | Stop retrying, wait for cooldown, rerun finalizer later. |
| MCP launcher exists but tools are not discovered | Do not claim MCP support; rerun release-declared registration/probe. |
| Bridge launcher exists but service is not online | Do not claim App Agent chat; start/verify through release-declared Bridge flow. |
| User asks for manual fix | Use only release-declared recovery actions unless the user explicitly chooses a manual path outside the Skill flow. |

## Completion Checklist

Report complete only when every item is true:

- remote health, HTTPS, and well-known checks pass
- App handoff page/package is available
- final user message includes the actual current 8-character setup code or verified
  QR/link
- App first setup completes
- user sets nickname and long-term login password
- selected connector or Bridge is online
- App-to-Agent messages round-trip
- `p2p-im` MCP server is registered in the selected runtime
- manifest-required MCP tools are discoverable
- MCP discovery has been recorded
- deployment status marks the relevant gates complete
- release manifest URL, release version, component versions, and repository ref
  are recorded in the handoff

## Non-Evidence

These are not enough to report completion:

- Docker container is running
- SSH can connect
- setup page opens
- plugin directory exists
- Bridge launcher or plist exists
- MCP launcher file exists
- Agent internal prompt got a reply
- old local `.env`, token file, launcher, or runtime config exists
- a manual fix looked healthy but release status did not record it
