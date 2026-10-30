#!/bin/sh
# Claude Code PreToolUse hook for Bash. Development is trunk-based, so a
# command that creates a branch, worktree or pull request asks the user first
# instead of running silently.
# Usage: configured in .claude/settings.json; reads the hook JSON on stdin.
set -e

command=$(jq -r '.tool_input.command // empty')

if printf '%s\n' "$command" | grep -Eq \
  'git[[:space:]]+(checkout[[:space:]]+-[bB]|switch[[:space:]]+(-[cC]|--create|--force-create)|branch[[:space:]]+[^-[:space:]]|worktree[[:space:]]+add)|gh[[:space:]]+pr[[:space:]]+create'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: "Trunk-based development: confirm you asked for a new branch, worktree or pull request (CODING_STANDARDS.md#git-workflow)."
    }
  }'
fi
