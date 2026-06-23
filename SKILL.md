---
name: p2p-matrix-deployer
description: Deploy, resume, verify, destroy, and locally wire a production P2P-IM Matrix server on AWS for Claude, Codex/OpenAI, Gemini, Cursor, Copilot, OpenClaw, Hermes, and other agent runtimes.
---

# P2P Matrix Deployer

This skill is the agent-facing deployment runbook for a production Direxio message server. It combines user confirmation, local tool checks, AWS provisioning, DNS waiting, service bootstrap, credential delivery, local agent wiring, verification, and teardown.

Agents should treat this repository root as the execution engine. The runnable entrypoints are:

```text
scripts/orchestrate.sh
scripts/destroy.sh
```

## Agent Recognition

Use this skill when the user asks to deploy, resume, verify, destroy, repair, or wire a P2P-IM Matrix server. The instructions are runtime-neutral and can be followed by Claude, Codex/OpenAI, Gemini, Cursor, Copilot, OpenClaw, Hermes, or another agent that can run shell commands and read files.

For agent skill installation after deployment, S6 installs `P2P-IM/p2p-agent-skill` into the current agent skills directory. Prefer `P2P_AGENT_SKILLS_DIR` when the host runtime exposes a custom skills path. Otherwise S6 checks common agent homes such as `CODEX_HOME`, `CLAUDE_HOME`, `GEMINI_HOME`, `CURSOR_HOME`, `COPILOT_HOME`, `OPENCLAW_HOME`, and `HERMES_HOME`.

During test refresh loops, set `P2P_SKIP_AGENT_SKILL_UPDATE=1` to skip writing, cloning, or pulling `p2p-agent-skill`. S6 still refreshes `~/.p2p-matrix/credentials.json` and `~/.p2p-matrix/env`; production runs default to installing/updating the skill.

## Core Rule

Deploy only to a real, long-lived domain. Matrix `server_name` is identity; changing it later is effectively a new homeserver with new accounts, rooms, federation identity, TURN realm, and client configuration.

Do not deploy until the user explicitly confirms:

```bash
DOMAIN=<final-domain>
DOMAIN_MODE=user
CONFIRM_DOMAIN_BINDING=1
```

Use `DOMAIN_MODE=route53` only when the domain is in Route53 and the user confirms AWS may manage the A record. Never use temporary `sslip.io`, IP-derived, localhost, wildcard, or disposable domains.

## Deployment Flow

1. Read `references/tooling.md`; inspect the user OS and install or prepare missing `bash`, `aws`, `jq`, `ssh`, `scp`, and `curl` only after approval.
2. Inspect DNS, AWS credentials, region defaults, local tooling, and existing deployment state before asking the user anything that can be discovered automatically.
3. Present one complete deployment configuration and request one consolidated confirmation covering the final domain and irreversible binding, DNS mode, AWS region and billing, credentials source, instance type, message-server image, required installs, and existing-state action.
4. Apply the approved existing-state action for `${P2P_WORKDIR:-$HOME/.p2p-matrix/deploy}/state.json`: continue, destroy, or use a new workdir.
5. Run `scripts/orchestrate.sh` with the confirmed environment. Let the state machine own AWS calls, state, polling, cloud-init, token/password handling, verification, and destroy behavior.
6. For `DOMAIN_MODE=user`, pause when the script emits an Elastic IP and ask the user to set:

```text
<DOMAIN>  A  <PUBLIC_IP>
```

7. After authoritative DNS resolves, rerun the same command with `DNS_READY=1`.
8. After S7 passes, read `references/runtime-wiring.md` and report the URL, `password`, agent token status, installed agent skill, persistent env status, resources, SSH command, state path, and destroy command.

## Destroy Flow

Use `scripts/destroy.sh` for teardown. After AWS resources are terminated and released, destroy removes the corresponding local deploy workdir under `~/.p2p-matrix` so stale state cannot block or mislead the next deployment. It may leave `~/.p2p-matrix/credentials.json` and unrelated deploy workdirs intact.

If an operator needs to preserve local state files for debugging, run destroy with `P2P_KEEP_WORKDIR=1` and explicitly report that the stale workdir remains.

## Image Refresh And Data Reset

When the user only asks to pull a newer image or reset application data on an existing EC2 instance, do not destroy cloud resources and do not delete TLS storage. Pull the compose images, stop the stack, remove only the application data volumes, restart, rerun `/opt/p2p/init-tokens.sh`, then reset local S5-S7 state so credentials and verification are refreshed.

Do not delete caddy-data or caddy-config during an image-only refresh. Removing Caddy's ACME storage loses the existing production certificate and can trigger CA duplicate-certificate rate limits. Preserve `caddy-data` and `caddy-config`; clear only `postgres-data message-config message-data` when the requested reset needs a clean homeserver/database.

For repeated test refreshes, pass `P2P_SKIP_AGENT_SKILL_UPDATE=1` when rerunning `scripts/orchestrate.sh` so S6 does not update the local agent skill on every token refresh.

## Minimal Invocation

```bash
AWS_DEFAULT_REGION=us-east-1 \
DOMAIN=im.example.com \
DOMAIN_MODE=user \
CONFIRM_DOMAIN_BINDING=1 \
INSTANCE_TYPE=t3.small \
MESSAGE_SERVER_IMAGE=direxio/message-server:latest \
bash scripts/orchestrate.sh
```

Use `AWS_PROFILE=p2p-matrix` or temporary `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`. Do not write AWS secrets, IM passwords, or agent tokens into skill files or the repository.

## Required Confirmation

Ask once, plainly and in the user's language. The confirmation message must summarize:

- Domain binding: `CONFIRM_DOMAIN_BINDING=1`.
- DNS mode: `user` or `route53`.
- AWS region and billable resources: EC2, Elastic IP, security group, EBS, network egress, TURN traffic.
- Instance type: default `t3.small`.
- Message-server image: default `direxio/message-server:latest`. The legacy `AS_IMAGE` variable is accepted as a compatibility alias.
- AWS credentials source and any elevated-risk credential choice such as root access keys.
- Existing state action: `continue`, `destroy`, or new `P2P_WORKDIR`.
- Network/system installs: package managers, AWS CLI, jq, Git Bash/MSYS2/WSL, Homebrew, apt/dnf/yum/pacman/zypper.

After the user confirms the summary, proceed without re-confirming individual fields. Ask again only when the configuration materially changes, an unapproved destructive action becomes necessary, or an external action such as DNS must be completed by the user.

## Delivery

After S7 passes, report:

```text
IM URL       : https://<DOMAIN>
password     : <login password>
agent_token  : written to ~/.p2p-matrix/credentials.json
agent skill   : installed in current agent skills
env vars      : P2P_MESSAGE_SERVER_URL, P2P_AGENT_TOKEN, credential tokens, and compatibility aliases persisted
AWS region   : <region>
EC2          : <instance-id> (<public-ip>)
SSH          : ssh -i <key-file> ubuntu@<public-ip>
state.json   : <state path>
Destroy      : bash scripts/destroy.sh
```

Mention that AWS resources keep billing until destroyed. User-managed DNS and purchased domains are not removed by destroy. After destroy, report which `~/.p2p-matrix` deploy workdir was removed or, if `P2P_KEEP_WORKDIR=1` was used, which one remains.

## References

- Tool setup by OS: `references/tooling.md`
- Deployment and resume workflow: `references/deployment-workflow.md`
- Runtime and agent wiring: `references/runtime-wiring.md`
- Verification and recovery: `references/verification-recovery.md`
- State machine details: `references/state-machine.md`
- Architecture and troubleshooting: `references/architecture.md`, `references/troubleshooting.md`
