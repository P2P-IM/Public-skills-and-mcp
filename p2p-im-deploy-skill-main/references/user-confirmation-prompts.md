# User Confirmation Prompts

Read this file before asking for confirmation on install, repair, reset,
upgrade, DNS/domain changes, paid cloud actions, data deletion, restore, local
runtime setup, MCP refresh, or Codex Bridge full access.

Use concise product language. Do not ask the user to choose script paths,
Docker tags, raw bundle IDs, or implementation details.

## New Install

Ask:

```text
I am going to create a new P2P IM node for domain <domain> in <region>.
The release manifest selected <plan_name> at <monthly_price> with this billing
note: <billing_note>.

This will create paid AWS resources. Please confirm:
1. the AWS account is active,
2. the domain/region/plan are correct,
3. you approve creating the paid resources.
```

If the user has no AWS account, switch to `aws-account-onboarding.md` and stop
deployment until the account is active.

## Non-Destructive Repair

Ask:

```text
I will repair <domain> without deleting user data. This path keeps the existing
node data and remote secrets, then re-runs release-declared health, token,
handoff, connector/Bridge, and MCP steps.

Please confirm that data must be kept and that I should run the release-declared
repair operation.
```

Do not call this reset.

## Clean Reset

Ask:

```text
Clean reset will back up the current node data for you, delete node data from
the server, rebuild the node, generate fresh App handoff, and force new
Gateway/Agent runtime sync.

Target domain: <domain>
Backup location after completion: <local_state_dir>

Please confirm that old node data can be removed from the server after backup.
```

If the user says to keep data, switch to non-destructive repair.

Clean reset confirmation does not cover node replacement. If the existing
instance cannot be reached because the recorded SSH key or state is missing,
stop and ask for key/state recovery. If the user wants replacement, ask a
separate confirmation that explicitly covers deleting the old instance, creating
a new instance, allocating/attaching a new static IP, DNS impact, downtime, and
cost.

## Upgrade

Ask:

```text
I will upgrade <domain> to release <release_version>/<release_ref>. This keeps
user data, preserves secrets, updates release-declared components, records
rollback evidence, and re-verifies App Agent chat plus MCP discovery.

Please confirm the target domain and release.
```

## DNS Or Domain Change

Ask:

```text
The release flow needs DNS for <domain> to point to <static_ip>. If a matching
Route53 hosted zone exists in your AWS account, I can use the release-declared
DNS sync. Otherwise I will stop and give you the exact DNS value to set
manually.

Please confirm the domain and DNS path.
```

## Codex Bridge Full Access

Ask only if the release manifest declares `requires_user_full_access_consent`:

```text
Codex Bridge needs full local Codex access so App Agent chat can use local
Codex and P2P IM MCP tools without hidden approval prompts during each message.
This does not allow token disclosure, and release scripts still write only the
declared Bridge configuration.

Please confirm whether to enable Codex Bridge full access for this P2P IM node.
```

If the user declines, stop local runtime setup for that runtime and report the
remaining gate.

## Recovery Action

Ask:

```text
The release operation stopped at <stage>. The manifest declares this recovery
action: <recovery_action>.

It may mutate <target>. Please confirm whether I should run this release-
declared recovery action.
```

Never present manual SSH, Docker, Caddy, database, volume, or token edits as the
normal recovery path.

## Final Handoff

Only after release-declared HTTPS handoff verification passes, say:

```text
Your P2P IM node is ready.

Domain: <domain>
Setup code: <8_digit_code>

Open the App, enter the domain and setup code, finish first setup, set your
nickname and long-term login password, then I will verify App-to-Agent chat and
MCP tool discovery.
```

Do not provide file paths, setup page instructions, long-lived tokens, consumed
codes, or "wait a few minutes" as a substitute for the current 8-character setup
code.
