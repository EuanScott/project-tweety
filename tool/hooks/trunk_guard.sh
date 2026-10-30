#!/bin/sh
# Claude Code PreToolUse hook. Development is trunk-based, so creating a
# branch, worktree or pull request asks the user first instead of running
# silently. Fails open: without jq, the tool call runs unguarded.
# Usage: configured in .claude/settings.json; reads the hook JSON on stdin.
set -e

ask() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: ($reason + " Trunk-based development: confirm the user asked for it (CODING_STANDARDS.md#git-workflow).")
    }
  }'
  exit 0
}

command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)

case $(printf '%s' "$input" | jq -r '.tool_name // empty') in
  EnterWorktree)
    ask 'Creates a worktree on a new branch.'
    ;;
  Agent)
    if [ "$(printf '%s' "$input" | jq -r '.tool_input.isolation // empty')" = worktree ]; then
      ask 'Runs a subagent in a new worktree branch.'
    fi
    exit 0
    ;;
esac

command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
# Strip quoted strings so commit messages or issue bodies that mention git/gh
# commands do not trigger false positives.
unquoted=$(printf '%s\n' "$command" | sed -E "s/'[^']*'/''/g; s/\"(\\\\.|[^\"\\\\])*\"/\"\"/g")

git_cmd='git([[:space:]]+(-[Cc][[:space:]]+[^[:space:]]+|--[[:alnum:]-]+(=[^[:space:]]+)?))*[[:space:]]+'
args='([[:space:]]+[^[:space:];&|]+)*'
end='([[:space:]]|$|[;&|])'
checkout_new="checkout$args[[:space:]]+(-[bBt]|--track|--orphan)$end"
switch_new="switch$args[[:space:]]+(-[cCt]|--create|--force-create|--track|--orphan)$end"
branch_new="branch([[:space:]]+(-f|--force|-t|--track|--no-track|-c|-C|--copy))*[[:space:]]+[[:alnum:]_./][^[:space:];&|>]*$end"
stash_new='stash[[:space:]]+branch[[:space:]]'
worktree_new='worktree[[:space:]]+add[[:space:]]'
pr_new='gh[[:space:]]+pr[[:space:]]+create'

if printf '%s\n' "$unquoted" | grep -Eq \
  "$git_cmd($checkout_new|$switch_new|$branch_new|$stash_new|$worktree_new)|$pr_new"; then
  ask 'Creates a branch, worktree or pull request.'
fi
