#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="${ROOT_DIR}/SKILL.md"
README="${ROOT_DIR}/README.md"
OPENAI_YAML="${ROOT_DIR}/agents/openai.yaml"
AWS_REF="${ROOT_DIR}/references/aws-account-onboarding.md"
PROMPTS_REF="${ROOT_DIR}/references/user-confirmation-prompts.md"
CHECKLIST_REF="${ROOT_DIR}/references/deployment-safety-checklist.md"

fail() {
  printf 'not ok - %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$file" || fail "expected ${file} to contain: ${expected}"
}

assert_not_contains() {
  local file="$1"
  local unexpected="$2"
  if grep -Fq -- "$unexpected" "$file"; then
    fail "expected ${file} not to contain: ${unexpected}"
  fi
}

assert_file() {
  local file="$1"
  [ -f "$file" ] || fail "missing required file: ${file}"
}

assert_file "$SKILL"
assert_file "$README"
assert_file "$OPENAI_YAML"
assert_file "$AWS_REF"
assert_file "$PROMPTS_REF"
assert_file "$CHECKLIST_REF"

skill_lines="$(wc -l < "$SKILL" | tr -d ' ')"
if [ "$skill_lines" -gt 340 ]; then
  fail "SKILL.md should stay short; got ${skill_lines} lines"
fi
if [ "$skill_lines" -lt 200 ]; then
  fail "SKILL.md is too thin to carry the deployment contract; got ${skill_lines} lines"
fi

assert_contains "$SKILL" 'version: "0.4.23"'
assert_contains "$SKILL" "Use when a user wants to install, deploy, update, repair, reset, or start using P2P IM"
assert_contains "$SKILL" "release_manifest:"
assert_contains "$SKILL" "https://raw.githubusercontent.com/P2P-IM/p2p-im-release/main/manifest.json"
assert_contains "$SKILL" "https://github.com/P2P-IM/p2p-im-release.git"
assert_not_contains "$SKILL" "raw.githubusercontent.com/yananli199307-dev"
assert_not_contains "$SKILL" "github.com/yananli199307-dev"

assert_contains "$SKILL" "This Skill is the stable, high-priority deployment contract."
assert_contains "$SKILL" "it is not a CLI"
assert_contains "$SKILL" "Release scripts stay inside"
assert_contains "$SKILL" 'Do not install or invent a standalone `p2p-im` CLI'
assert_contains "$SKILL" "Layer Contract"
assert_contains "$SKILL" "Skill main rules"
assert_contains "$SKILL" "Skill references"
assert_contains "$SKILL" "Release contract"
assert_contains "$SKILL" "Release scripts"
assert_contains "$SKILL" "Runtime resources"

assert_contains "$SKILL" "Reference Loading"
assert_contains "$SKILL" "references/aws-account-onboarding.md"
assert_contains "$SKILL" "references/user-confirmation-prompts.md"
assert_contains "$SKILL" "references/deployment-safety-checklist.md"

assert_contains "$SKILL" "First Rule: Manifest Before Action"
assert_contains "$SKILL" "Manifest access order"
assert_contains "$SKILL" "min_skill_version"
assert_contains "$SKILL" "operation is missing"
assert_contains "$SKILL" "selected Agent runtime is unsupported"
assert_contains "$SKILL" "Do not invent image tags"

assert_contains "$SKILL" "Intent Is Not Permission"
assert_contains "$SKILL" "confirm"
assert_contains "$SKILL" "exact domain or node"
assert_contains "$SKILL" "whether user data must be kept or deleted"
assert_contains "$SKILL" "paid-resource consent"

assert_contains "$SKILL" "AWS Account And Instance Gate"
assert_contains "$SKILL" "active AWS"
assert_contains "$SKILL" "stop deployment until the account is active"
assert_contains "$SKILL" "Never collect"
assert_contains "$SKILL" "root password"
assert_contains "$SKILL" "MFA code"
assert_contains "$SKILL" "AWS secret access key"
assert_contains "$SKILL" "agent_deployment.lightsail_plan_recommendations"
assert_contains "$SKILL" "Present only"
assert_contains "$SKILL" "release-declared choices and prices"
assert_contains "$SKILL" "Before creating paid resources"

assert_contains "$SKILL" "Operation Routing"
assert_contains "$SKILL" "Run only manifest-declared scripts"
assert_contains "$SKILL" "route by operation key"
assert_contains "$SKILL" "deployment status"
assert_contains "$SKILL" "synthetic state file"

assert_contains "$SKILL" "Deployment Layers"
assert_contains "$SKILL" "Remote node"
assert_contains "$SKILL" "Real-time App Agent chat connector"
assert_contains "$SKILL" "MCP tool layer"
assert_contains "$SKILL" "App handoff and verification"

assert_contains "$SKILL" "Token Model"
assert_contains "$SKILL" 'P2P_IM_PORTAL_PASSWORD'
assert_contains "$SKILL" 'P2P_IM_ADMIN_ACCESS_TOKEN'
assert_contains "$SKILL" 'P2P_IM_GATEWAY_TOKEN'
assert_contains "$SKILL" 'P2P_IM_AGENT_TOKEN'
assert_contains "$SKILL" 'agent_token'
assert_contains "$SKILL" 'P2P_IM_CHANNEL_TOKEN'
assert_contains "$SKILL" 'P2P_IM_MCP_TOKEN'
assert_contains "$SKILL" "Normal new-device"

assert_contains "$SKILL" "Runtime Gates"
assert_contains "$SKILL" "Hermes and OpenClaw use native channel plugins"
assert_contains "$SKILL" "Codex uses Bridge"
assert_contains "$SKILL" "Generating a launcher, copying a plugin, or writing an MCP config is not enough"
assert_contains "$SKILL" 'list_contacts'
assert_contains "$SKILL" 'list_groups'
assert_contains "$SKILL" 'search_messages'
assert_contains "$SKILL" 'send_message'
assert_contains "$SKILL" "Codex MCP registration must not place Gateway"

assert_contains "$SKILL" "No Ad-Hoc Recovery"
assert_contains "$SKILL" "If a release-declared script fails, stop at that stage"
assert_contains "$SKILL" "Manual SSH is read-only diagnostics"
assert_contains "$SKILL" 'Do not create synthetic `state.json`'
assert_contains "$SKILL" "Do not hand-edit"
assert_contains "$SKILL" '`Caddyfile`'
assert_contains "$SKILL" '`registration.yaml`'
assert_contains "$SKILL" '`docker-compose.yml`'
assert_contains "$SKILL" '`.env`'

assert_contains "$SKILL" "App Handoff Rules"
assert_contains "$SKILL" "8-character setup code"
assert_contains "$SKILL" "after public HTTPS handoff verification"
assert_contains "$SKILL" "POST /_as/portal/setup"
assert_contains "$SKILL" "Do not read setup information directly"
assert_contains "$SKILL" "from the database"
assert_contains "$SKILL" "401 or 403"
assert_contains "$SKILL" "429"

assert_contains "$SKILL" "Reset, Repair, And Upgrade Boundaries"
assert_contains "$SKILL" "Repair keeps data"
assert_contains "$SKILL" "Clean reset means backup user data"
assert_contains "$SKILL" "Clean reset is not node replacement"
assert_contains "$SKILL" "Node replacement needs a separate destructive paid-resource"
assert_contains "$SKILL" "confirmation naming old instance deletion"
assert_contains "$SKILL" "Upgrade keeps user data"

assert_contains "$SKILL" "Blacklist"
assert_contains "$SKILL" "skip manifest reading"
assert_contains "$SKILL" "use an undeclared standalone CLI"
assert_contains "$SKILL" "treat clean-reset approval as permission to provision or replace a node"
assert_contains "$SKILL" "claim MCP works before runtime tool discovery succeeds"

assert_contains "$SKILL" "Completion Standard"
assert_contains "$SKILL" "App-to-Agent messages round-trip"
assert_contains "$SKILL" '`p2p-im` MCP server is registered'
assert_contains "$SKILL" "required MCP tools are discoverable"
assert_contains "$SKILL" "Do not report completion based only on"

assert_contains "$AWS_REF" "AWS Account Onboarding"
assert_contains "$AWS_REF" "https://aws.amazon.com/resources/create-account/"
assert_contains "$AWS_REF" "https://docs.aws.amazon.com/accounts/latest/reference/accounts-welcome.html"
assert_contains "$AWS_REF" "https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html"
assert_contains "$AWS_REF" "Account Readiness Gate"
assert_contains "$AWS_REF" "Official AWS Signup Flow"
assert_contains "$AWS_REF" "What The Agent Must Not Ask"
assert_contains "$AWS_REF" "payment card number"
assert_contains "$AWS_REF" "root password"
assert_contains "$AWS_REF" "MFA code"
assert_contains "$AWS_REF" "Instance Selection"
assert_contains "$AWS_REF" "agent_deployment.lightsail_plan_recommendations"
assert_contains "$AWS_REF" "Stop Conditions"

assert_contains "$PROMPTS_REF" "User Confirmation Prompts"
assert_contains "$PROMPTS_REF" "New Install"
assert_contains "$PROMPTS_REF" "Non-Destructive Repair"
assert_contains "$PROMPTS_REF" "Clean Reset"
assert_contains "$PROMPTS_REF" "Clean reset confirmation does not cover node replacement"
assert_contains "$PROMPTS_REF" "deleting the old instance"
assert_contains "$PROMPTS_REF" "Upgrade"
assert_contains "$PROMPTS_REF" "DNS Or Domain Change"
assert_contains "$PROMPTS_REF" "Codex Bridge Full Access"
assert_contains "$PROMPTS_REF" "Recovery Action"
assert_contains "$PROMPTS_REF" "Final Handoff"
assert_contains "$PROMPTS_REF" "recovery action"
assert_contains "$PROMPTS_REF" "current 8-character setup"

assert_contains "$CHECKLIST_REF" "Deployment Safety Checklist"
assert_contains "$CHECKLIST_REF" "Pre-Mutation Checklist"
assert_contains "$CHECKLIST_REF" "Clean reset is confirmed as existing-node reset only"
assert_contains "$CHECKLIST_REF" "Stage Checks"
assert_contains "$CHECKLIST_REF" "Failure Handling"
assert_contains "$CHECKLIST_REF" "SSH key missing during clean reset"
assert_contains "$CHECKLIST_REF" "Completion Checklist"
assert_contains "$CHECKLIST_REF" "Non-Evidence"
assert_contains "$CHECKLIST_REF" "MCP launcher exists but tools are not discovered"
assert_contains "$CHECKLIST_REF" "Bridge launcher exists but service is not online"

assert_contains "$README" "Stable Skill layer"
assert_contains "$README" "does not contain"
assert_contains "$README" "standalone CLI"
assert_contains "$README" "five layers"
assert_contains "$README" "Skill references"
assert_contains "$README" "p2p-im-release/scripts"
assert_contains "$README" 'Do not create a `p2p-im-cli` repository for this phase.'
assert_contains "$README" "No ad-hoc recovery"
assert_contains "$README" "bash tests/skill_contract_test.sh"

assert_contains "$OPENAI_YAML" 'Use $p2p-im-deploy'
assert_contains "$OPENAI_YAML" "confirm AWS/account/safety gates"
assert_contains "$OPENAI_YAML" "release-declared operations"

assert_not_contains "$SKILL" "ea001/p2p-im-as:latest"
assert_not_contains "$SKILL" "scripts/deploy-compose-node.sh"
assert_not_contains "$SKILL" "scripts/prepare-local-agent-runtime.sh"
assert_not_contains "$SKILL" "test reset"
assert_not_contains "$README" "test reset"

if [ -d "${ROOT_DIR}/scripts" ]; then
  fail "stable skill repo must not bundle runtime scripts"
fi

printf 'ok - stable skill contract tests passed\n'
