---
name: p2p-im-deploy
description: Use when a user wants to install, deploy, update, repair, reset, or start using P2P IM, including ordinary requests like "use P2P IM", "I want to use this product", "deploy P2P IM", "repair P2P IM", "install p2p-mcp-server", or "connect my Agent to the App".
metadata:
  version: "0.4.23"
  release_manifest: "https://raw.githubusercontent.com/P2P-IM/p2p-im-release/main/manifest.json"
  release_repository: "https://github.com/P2P-IM/p2p-im-release.git"
  compatibleAgents: ["hermes", "openclaw", "codex", "claude-code", "cursor", "opencode"]
  triggers:
    - use P2P IM
    - I want to use this product
    - install this product
    - deploy P2P IM
    - install P2P IM node
    - reset P2P IM node
    - update P2P IM
    - upgrade P2P IM
    - repair P2P IM deployment
    - P2P IM is broken
    - install P2P IM Agent connector
    - install p2p-mcp-server
---

# P2P IM Deploy Skill

This Skill is the stable, high-priority deployment contract. It tells an Agent
what it must read, what it must ask, where it must stop, and what it must never
do. It is not the deployment runbook and it is not a CLI.

The release manifest is the machine-readable source of truth for image tags,
scripts, script arguments, supported runtimes, instance bundles, recovery
actions, quality gates, and component versions. Release scripts stay inside
`p2p-im-release/scripts` and are invoked only through manifest-declared
operation keys. Do not install or invent a standalone `p2p-im` CLI for this
flow.

## Layer Contract

Use five layers and keep their authority separate:

1. Skill main rules: mandatory behavior, safety stops, and completion standard.
2. Skill references: stable user guidance and checklists loaded only when needed.
3. Release contract: `manifest.json`, release files, release docs, and gates.
4. Release scripts: the actual install, update, repair, reset, status, and
   handoff executors.
5. Runtime resources: AWS, Docker Hub images, `p2p-as`, connector plugins,
   Bridge, `p2p-mcp-server`, App packages, and generated handoff files.

Ordinary users do not need this layer vocabulary. Speak in product terms:
account, domain, region, node, install, update, repair, reset, App login,
Agent chat, and MCP tools.

## Reference Loading

Read only the reference files required by the current task:

- Read `references/aws-account-onboarding.md` before new install, cloud
  provisioning, AWS readiness checks, account creation guidance, instance
  selection, or paid-resource confirmation.
- Read `references/user-confirmation-prompts.md` before asking the user to
  confirm install, repair, reset, upgrade, domain/DNS changes, paid cloud
  actions, data deletion, restore, or Codex Bridge full access.
- Read `references/deployment-safety-checklist.md` before any mutating release
  operation and before reporting completion.

Do not duplicate long reference content in the main Skill. If a detail lives in
a reference or in the release manifest, load that source and follow it.

## First Rule: Manifest Before Action

Before install, update, repair, reset, rollback, plugin setup, Bridge setup,
MCP setup, local component update, or App handoff, fetch the release manifest
from `metadata.release_manifest`.

Manifest access order:

1. Fetch the public HTTPS manifest.
2. If access fails because the release repository is private, use authenticated
   GitHub access without printing tokens: `gh api` or an authenticated clone of
   `metadata.release_repository`.
3. If neither path works, stop and ask for repository access or a public
   manifest endpoint.

If a local release checkout is used, verify the local manifest version and git
revision before any mutation. Stop if the local checkout is stale, if
`min_skill_version` is higher than this Skill version, if the requested
operation is missing, if the selected Agent runtime is unsupported, or if the
manifest marks the operation unsafe/manual-only.

Do not invent image tags, repository URLs, script paths, app package URLs,
component versions, instance bundle IDs, recovery actions, or quality gates
outside the manifest.

## Intent Is Not Permission

Treat "install", "reset", "upgrade", "repair", and "something is broken" as
intent signals, not execution permission.

Before any mutating script, cloud write, remote SSH change, local runtime config
change, Gateway restart, data deletion, restore, paid action, DNS write, or App
handoff reset, confirm:

- exact domain or node
- operation type: new install, non-destructive repair, upgrade, clean reset,
  rollback, local runtime setup, MCP refresh, or App handoff refresh
- whether user data must be kept or deleted
- region, instance plan, and paid-resource consent when cloud resources are used
- current release/ref and release-declared operation key

If the user reports a problem without choosing repair/reset/upgrade, run only
read-only status, health, and diagnostic checks until the user confirms a
mutating operation.

## AWS Account And Instance Gate

For a new AWS/Lightsail install, ask whether the user already has an active AWS
account that can create Lightsail resources. If not, read
`references/aws-account-onboarding.md`, guide the user through AWS account
creation in their browser, and stop deployment until the account is active.

Never collect, request, paste, log, or store the user's payment card details,
root password, email verification code, phone verification code, MFA code, root
access key, AWS secret access key, Portal password, Admin access token, Gateway
token, or Agent token.

For instance selection, use the release manifest's current deployment plan
fields such as `agent_deployment.lightsail_plan_recommendations`. Present only
release-declared choices and prices. If the user is unsure, default to the
manifest-declared default plan. Use product sizing language: expected friends,
groups, channels, retained history, media volume, and Agent/MCP activity.

Before creating paid resources, show the release-declared monthly price,
billing note, selected region, domain/DNS decision, and deletion requirement.
Do not create paid resources until the user explicitly confirms.

## Operation Routing

Run only manifest-declared scripts with manifest-declared arguments. The Skill
must route by operation key, not by remembered shell commands. Common release
operation keys include deployment planning, confirmed-plan guard, Compose
deployment, clean reset, runtime secret sync, App handoff finalization, local
Agent runtime preparation, local component update, MCP discovery recording,
deployment status, and rollback.

After every mutating stage, read the release-declared deployment status and
resume from that state. Do not skip ahead from memory, old logs, old local env
files, old Bridge launchers, old plugin settings, old MCP launchers, or a
synthetic state file.

## Deployment Layers

A complete deployment has four product layers:

1. Remote node: AWS/DNS/Docker Compose, Matrix/Dendrite, `p2p-as`, Caddy/TLS,
   TURN, health checks, and App handoff endpoints.
2. Real-time App Agent chat connector: native Hermes/OpenClaw channel plugin or
   release-declared Bridge provider.
3. MCP tool layer: `p2p-mcp-server` registered in the selected Agent runtime
   and authorized for owner-approved tools.
4. App handoff and verification: domain, short setup code or QR/link, App
   first setup/login, Agent chat round trip, and MCP tool discovery.

The deployment is incomplete if either the real-time connector/Bridge or MCP is
missing.

## Token Model

Keep credential roles separate even if the current backend stores a shared
Gateway/Agent fallback:

- `P2P_IM_PORTAL_PASSWORD` / Portal password file: App normal login password.
- `P2P_IM_ADMIN_ACCESS_TOKEN` / Admin access token file: owner-only Admin API
  and release-only App setup-code generation after verified HTTPS handoff.
- `P2P_IM_GATEWAY_TOKEN` / Gateway token file: native channel plugins and
  Bridge real-time App Agent chat.
- `P2P_IM_AGENT_TOKEN` / Agent token file: `p2p-mcp-server` tool authorization.
- `bootstrap-credentials.json`: backend automatic first-run credential handoff
  synced from the node and stored only as a local 0600 release artifact.

Current backend releases persist `agent_token` and use it as the default
Gateway token when no explicit gateway override exists. Still keep local file
names, env names, reports, and consumers role-separated. Legacy
`P2P_IM_CHANNEL_TOKEN` and `P2P_IM_MCP_TOKEN` are migration aliases only.

Never give the user a long-lived token as an App setup code. Normal new-device
login uses the owner's long-term login password, not a setup code.

## Runtime Gates

Hermes and OpenClaw use native channel plugins when release support exists.
Codex uses Bridge only when the manifest declares the provider and transport.
Claude Code, Cursor, OpenCode, or any unknown runtime must stop unless the
manifest declares a connector or Bridge provider.

Generating a launcher, copying a plugin, or writing an MCP config is not enough:

- Native connector support requires runtime config, current Gateway token, the
  required runtime restart or reload, and release-declared channel verification.
- Bridge support requires prepared runtime, started service mode, backend Agent
  online status, and App-to-Agent message round trip.
- MCP support requires the runtime MCP server list to contain `p2p-im` and
  discover the manifest-required tools such as `list_contacts`, `list_groups`,
  `search_messages`, and `send_message`.

Codex Bridge must use the manifest-declared provider transport. If the manifest
requires user full-access consent, ask once using the confirmation reference,
then let the release script write the declared Bridge environment. Do not ask
the user to chase hidden runtime approval popups.

Codex MCP registration must not place Gateway, Admin, Portal password, legacy
Channel/MCP, bootstrap credential, or setup-code values in Codex config.

## No Ad-Hoc Recovery

If a release-declared script fails, stop at that stage. Report the failed
operation key, stage, endpoint, and log source. Use only release-declared
recovery actions after explicit user confirmation.

Do not switch from a failed release script to manual SSH repair, manual Docker
commands, direct database reads, HTTP fallback calls, hand-written config
rewrites, Caddy rewrites, registration rewrites, volume deletion, instance
reboot, or instance stop/start unless a release-declared recovery operation is
performing that mutation.

Manual SSH is read-only diagnostics unless a release script performs the
mutation. A single SSH failure or a single successful `ssh echo OK` is not
enough evidence to blame the VPS image, Docker networking, or the user's VPN.

Do not create synthetic `state.json` or fake progress markers. Do not hand-edit
remote `Caddyfile`, `registration.yaml`, `docker-compose.yml`, `.env`, or old
`/opt/p2p` bundles during the standard flow. Update the release package and
rerun the declared renderer, bootstrap, repair, reset, or finalizer.

## App Handoff Rules

The final App handoff is domain plus a current 8-character setup code or an
equivalent release-generated QR/link. The setup code must come from the
release-generated setup-code file after public HTTPS handoff verification. On
the current backend, the release finalizer uses the owner Admin access token
synced from `bootstrap.json` to call `POST /_as/portal/setup`.

Do not hand over a setup code while DNS, Docker networking, TLS, Caddy, or
public HTTPS verification is unstable. Do not read setup information directly
from the database, scrape setup pages, call undeclared HTTP endpoints, restart
services to obtain a code, or substitute Portal password, Admin access token,
Gateway token, Agent token, bootstrap credential, or setup page values as an
App setup code.

If setup-code generation returns 401 or 403, treat it as stale or mismatched
Admin access token evidence and rerun the release-declared bootstrap/runtime
token sync path. If it returns 429, stop retrying, wait for the backend
cooldown, then rerun the release-declared finalizer. Do not restart `p2p-as`
only to clear the rate limit.

## Reset, Repair, And Upgrade Boundaries

Repair keeps data and fixes health, release drift, runtime tokens, App handoff,
connector/Bridge, MCP, or version drift.

Clean reset means backup user data for the user, delete node data from the
server, rebuild the node, re-sync Gateway and Agent token files, regenerate App
handoff, and require fresh App/Agent verification. If the user says reset,
reinstall, clean reset, rebuild from zero, or start over, do not use a
non-destructive repair path unless the user explicitly says to keep data.
Clean reset is not node replacement. If the current node state or recorded SSH
key is missing or unusable, stop reset. Do not delete/recreate the instance,
allocate a new static IP, update DNS, or run provisioning from clean-reset
confirmation. Node replacement needs a separate destructive paid-resource
confirmation naming old instance deletion, new instance creation, IP/DNS impact,
and downtime.

Upgrade keeps user data, preserves secrets, updates release-declared
components, records rollback evidence, and reruns connector/MCP verification.

## Blacklist

Never do these in this Skill flow:

- skip manifest reading or deploy from memory
- ask the user to choose raw script paths, Docker tags, or bundle IDs
- use an undeclared standalone CLI
- create paid resources without explicit confirmation
- collect root credentials, verification codes, MFA codes, payment details, or
  secret access keys
- expose Portal password, Admin access token, Gateway token, Agent token, setup
  issuer, legacy Channel/MCP, PEM, `.env`, database, bootstrap credential, or
  setup secret values
- call manual fixes "complete" when release status does not record completion
- treat clean-reset approval as permission to provision or replace a node
- claim App Agent chat works before connector/Bridge is online and round trip
  succeeds
- claim MCP works before runtime tool discovery succeeds and is recorded
- deliver a 64-character token or consumed code as the App setup code

## Completion Standard

Report complete only when release status and direct checks prove:

- remote health, HTTPS, and well-known checks pass
- App handoff page/package is available
- the user receives the actual current 8-character setup code or verified QR/link
- App first setup completes with nickname and long-term login password
- the selected native connector or Bridge is online
- App-to-Agent messages round-trip
- `p2p-im` MCP server is registered in the selected runtime
- required MCP tools are discoverable
- MCP discovery is recorded by the release-declared recorder
- release manifest URL, release version, component versions, and repository ref
  are recorded in the final handoff

Do not report completion based only on a running Docker container, reachable
SSH, an installed plugin directory, a generated Bridge launcher, an MCP launcher
file, an open setup page, or an Agent internal chat response.
