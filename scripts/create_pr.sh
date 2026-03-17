#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
DEFAULT_BASE_BRANCH="dev"

BASE_BRANCH="$DEFAULT_BASE_BRANCH"
TITLE=""
BODY_FILE=""
IS_DRAFT=0
RUN_BUILD=1
RUN_TEST=0
RUN_LINT=0
AUTO_YES=0

TEMP_BODY_FILE=""

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Interactive helper for creating a GitHub PR from the current branch.

Options:
  -b, --base <branch>       Base branch (default: $DEFAULT_BASE_BRANCH)
  -t, --title <title>       PR title (skip interactive title prompt)
  -f, --body-file <file>    Use body from file (skip editor prompt)
  -d, --draft               Create PR as draft
      --skip-build          Skip xcodebuild build preflight check
      --run-test            Run xcodebuild test preflight check
      --run-lint            Run swiftlint preflight check
  -y, --yes                 Accept defaults for prompts where possible
  -h, --help                Show this help
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

prompt_input() {
  local prompt="$1"
  local default="${2:-}"
  local value

  if [[ -n "$default" ]]; then
    read -r -p "$prompt [$default]: " value
    echo "${value:-$default}"
  else
    read -r -p "$prompt: " value
    echo "$value"
  fi
}

confirm() {
  local prompt="$1"
  local default="${2:-N}" # Y or N
  local answer

  if [[ "$AUTO_YES" -eq 1 ]]; then
    [[ "$default" == "N" ]] && return 1
    return 0
  fi

  if [[ "$default" == "Y" ]]; then
    read -r -p "$prompt [Y/n]: " answer
    [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]
  else
    read -r -p "$prompt [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]]
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--base)
      BASE_BRANCH="${2:-}"
      shift 2
      ;;
    -t|--title)
      TITLE="${2:-}"
      shift 2
      ;;
    -f|--body-file)
      BODY_FILE="${2:-}"
      shift 2
      ;;
    -d|--draft)
      IS_DRAFT=1
      shift
      ;;
    --skip-build)
      RUN_BUILD=0
      shift
      ;;
    --run-test)
      RUN_TEST=1
      shift
      ;;
    --run-lint)
      RUN_LINT=1
      shift
      ;;
    -y|--yes)
      AUTO_YES=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

for cmd in git gh; do
  command -v "$cmd" >/dev/null 2>&1 || die "Missing required command: $cmd"
done

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$REPO_ROOT" ]] || die "Not inside a git repository."
cd "$REPO_ROOT"

CURRENT_BRANCH="$(git branch --show-current)"
[[ -n "$CURRENT_BRANCH" ]] || die "Not on a branch (detached HEAD)."

if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "dev" ]]; then
  confirm "Current branch is '$CURRENT_BRANCH'. Continue anyway?" "N" || exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  die "Working tree is not clean. Commit/stash changes before creating a PR."
fi

git show-ref --verify --quiet "refs/heads/$BASE_BRANCH" || die "Base branch '$BASE_BRANCH' not found locally."

echo "Head branch: $CURRENT_BRANCH"
echo "Base branch: $BASE_BRANCH"

if [[ -z "$TITLE" ]]; then
  TITLE="$(prompt_input "PR title")"
fi
[[ -n "$TITLE" ]] || die "PR title cannot be empty."

if [[ -n "$BODY_FILE" ]]; then
  [[ -f "$BODY_FILE" ]] || die "Body file not found: $BODY_FILE"
else
  TEMP_BODY_FILE="$(mktemp /tmp/dotmap_pr_body.XXXXXX)"
  BODY_FILE="$TEMP_BODY_FILE"
  TEMPLATE_FILE="$REPO_ROOT/.github/pull_request_template.md"

  if [[ -f "$TEMPLATE_FILE" ]]; then
    cp "$TEMPLATE_FILE" "$BODY_FILE"
  else
    cat > "$BODY_FILE" <<'EOF'
## What

## Why

## Notes

## Testing
- [ ] xcodebuild build -project src/dotmap.xcodeproj -scheme dotmap -quiet
- [ ] xcodebuild test -project src/dotmap.xcodeproj -scheme dotmap -quiet
- [ ] swiftlint lint --strict
- [ ] Manual verification completed

Manual test notes:
- 

## Checklist
- [ ] Targets `dev`
- [ ] No direct commits to `main`/`dev`
- [ ] User-visible changes documented in `CHANGELOG.md` (`[Unreleased]`) when applicable
- [ ] No force unwraps (`!`) or `try!` in production paths
- [ ] Parser behavior preserves unrecognized content as `.unmanaged(raw:)` when parser code is touched
EOF
  fi

  echo "Opening PR body in editor: ${EDITOR:-vi}"
  "${EDITOR:-vi}" "$BODY_FILE"
fi

[[ -s "$BODY_FILE" ]] || die "PR body file is empty: $BODY_FILE"

if [[ "$RUN_BUILD" -eq 1 ]] && confirm "Run build check?" "Y"; then
  xcodebuild build -project src/dotmap.xcodeproj -scheme dotmap -quiet
fi

if [[ "$RUN_TEST" -eq 1 ]] && confirm "Run test check?" "Y"; then
  xcodebuild test -project src/dotmap.xcodeproj -scheme dotmap -quiet
fi

if [[ "$RUN_LINT" -eq 1 ]] && confirm "Run swiftlint check?" "Y"; then
  command -v swiftlint >/dev/null 2>&1 || die "swiftlint not found."
  swiftlint lint --strict
fi

if confirm "Push branch '$CURRENT_BRANCH' to origin before creating PR?" "Y"; then
  git push -u origin "$CURRENT_BRANCH"
fi

EXISTING_PR_URL="$(gh pr list --head "$CURRENT_BRANCH" --base "$BASE_BRANCH" --state open --json url --jq '.[0].url // ""' 2>/dev/null || true)"
if [[ -n "$EXISTING_PR_URL" ]]; then
  echo "Open PR already exists: $EXISTING_PR_URL"
  echo "Use: gh pr edit \"$EXISTING_PR_URL\" to update title/body."
  [[ -n "$TEMP_BODY_FILE" ]] && rm -f "$TEMP_BODY_FILE"
  exit 0
fi

CREATE_ARGS=(
  pr create
  --base "$BASE_BRANCH"
  --head "$CURRENT_BRANCH"
  --title "$TITLE"
  --body-file "$BODY_FILE"
)

if [[ "$IS_DRAFT" -eq 1 ]]; then
  CREATE_ARGS+=(--draft)
fi

PR_URL="$(gh "${CREATE_ARGS[@]}")"
echo "Created PR: $PR_URL"

if [[ -n "$TEMP_BODY_FILE" ]]; then
  rm -f "$TEMP_BODY_FILE"
fi
