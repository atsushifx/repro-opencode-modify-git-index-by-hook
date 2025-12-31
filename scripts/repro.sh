#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Configuration
# ============================================================

MODEL="openai/gpt-5.2"

PROMPT=$(cat <<'EOF'
This agent analyzes staged files and prepares a commit message.

The repository is in a prepared state for commit.
Follow standard Conventional Commits conventions.
EOF
)

# ============================================================
# Utilities
# ============================================================

require_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "ERROR: not inside a git repository" >&2
    exit 1
  }
}

index_tree_hash() {
  git write-tree
}

run_agent() {
  {
    echo "$PROMPT"
    echo
    git diff --cached
  } | opencode run --model "$MODEL"
}

# ============================================================
# Main
# ============================================================

echo "== Repro: prompt + blank line + git diff --cached =="

require_git_repo

echo
echo "## git status (initial)"
git status --short

echo
echo "## index BEFORE"
before_tree="$(index_tree_hash)"
echo "$before_tree"

echo
echo "## running opencode (agent input)"
run_agent

echo
echo "## index AFTER"
after_tree="$(index_tree_hash)"
echo "$after_tree"

echo
echo "## index tree diff"
if [[ "$before_tree" == "$after_tree" ]]; then
  echo "OK: index tree unchanged"
else
  echo "ERROR: index tree CHANGED"
  exit 1
fi
