#!/bin/bash
# The Joint Keepers demo command. Run it from Terminal in the joint-keepers folder:
#
#   ./demo.sh check      check this Mac is ready, without changing anything
#   ./demo.sh ready      get everything to the starting point before a demo
#   ./demo.sh prompt 1   copy the hop 1 prompt, ready to paste into Cosine
#   ./demo.sh prove      send Cosine's change to GitHub, build it, check it and put it on Azure
#   ./demo.sh jump NAME  go straight to a checkpoint: 'start', or 'hop1' once it is chosen
#   ./demo.sh reset      after a demo: stop the app on Azure
#
# Every build and check runs on GitHub. This Mac only needs Git, the GitHub command
# line tool (gh), signed in, and Cosine.

set -u

LEGACY_WORKFLOW=legacy.yml
AZURE_WORKFLOW=azure.yml
DEPLOY_STEP="Deploy the legacy app to Azure App Service"
FALLBACK_SCREENS=demo/screens/joint-keepers
SCRIPT_NAME=${0##*/}

cd "$(dirname "$0")" || exit 1

say()  { printf '\n%s\n' "$*"; }
ok()   { printf '  ok      %s\n' "$*"; }
bad()  { printf '  PROBLEM %s\n' "$*"; }
fail() { printf '\nStopped: %s\n' "$*" >&2; exit 1; }
stamp() { date +%d%m-%H%M%S; }

# ---- Checks ---------------------------------------------------------------

check_mac() {
  local problems=0 permission
  say "Checking this Mac"
  # On a Mac without the developer tools, 'git' exists but only offers to install them.
  if git --version >/dev/null 2>&1; then ok "Git is installed"; else bad "Git is not installed (install guide, step 1)"; problems=1; fi
  if [ -n "$(git config user.name 2>/dev/null)" ] && [ -n "$(git config user.email 2>/dev/null)" ]; then
    ok "Git knows your name and email"
  else
    bad "Git does not know your name and email (install guide, step 1)"; problems=1
  fi
  if command -v gh >/dev/null 2>&1; then
    ok "GitHub command line tool is installed"
    if gh auth status >/dev/null 2>&1; then
      ok "Signed in to GitHub"
      permission=$(gh repo view --json viewerPermission --jq .viewerPermission 2>/dev/null)
      case "$permission" in
        WRITE|MAINTAIN|ADMIN) ok "You can send changes to the demo on GitHub" ;;
        *) bad "Your GitHub account cannot send changes to the demo yet: accept Seb's invitation, or ask him for one"; problems=1 ;;
      esac
    else
      bad "Not signed in to GitHub: run 'gh auth login' (install guide, step 2)"; problems=1
    fi
  else
    bad "GitHub command line tool is not installed (install guide, step 2)"; problems=1
  fi
  if command -v cos2 >/dev/null 2>&1 || command -v cos >/dev/null 2>&1; then ok "Cosine is installed"; else bad "Cosine is not installed (install guide, step 3)"; problems=1; fi
  if [ "$problems" -ne 0 ]; then fail "fix the problems above, then run this again."; fi
}

# ---- GitHub helpers ---------------------------------------------------------

# Start a workflow and print the new run's number.
start_workflow() { # workflow branch [extra gh arguments]
  local workflow=$1 branch=$2; shift 2
  local before output id _
  before=$(gh run list --workflow "$workflow" --branch "$branch" --event workflow_dispatch --limit 1 \
             --json databaseId --jq '.[0].databaseId // 0' 2>/dev/null) || before=unknown
  output=$(gh workflow run "$workflow" --ref "$branch" "$@" 2>&1) || fail "GitHub would not start the $workflow build. Check your GitHub access."
  # Recent versions of gh print the new run's address; its last part is the run number.
  id=$(printf '%s\n' "$output" | sed -n 's#.*/actions/runs/\([0-9][0-9]*\).*#\1#p' | tail -1)
  if [ -n "$id" ]; then echo "$id"; return 0; fi
  # Older versions print nothing useful, so wait for GitHub to list the new run.
  [ "$before" = "unknown" ] && fail "could not read GitHub's list of builds. Check the internet connection."
  for _ in $(seq 1 30); do
    sleep 2
    id=$(gh run list --workflow "$workflow" --branch "$branch" --event workflow_dispatch --limit 1 \
           --json databaseId --jq '.[0].databaseId // 0' 2>/dev/null) || continue
    if [ "$id" != "0" ] && [ "$id" != "$before" ]; then echo "$id"; return 0; fi
  done
  fail "GitHub did not show the new $workflow run after a minute."
}

# The build a push started by itself, if there is one, for this commit.
run_for_commit() { # branch sha
  local id _
  for _ in $(seq 1 10); do
    sleep 3
    id=$(gh run list --workflow "$LEGACY_WORKFLOW" --branch "$1" --commit "$2" --limit 1 \
           --json databaseId --jq '.[0].databaseId // empty' 2>/dev/null)
    if [ -n "$id" ]; then echo "$id"; return 0; fi
  done
  return 1
}

follow_run() { # run-id; returns non-zero if the run failed
  gh run watch "$1" --exit-status --interval 5
}

deployed_in() { # run-id; true if that run put the app on Azure
  [ "$(gh run view "$1" --json jobs --jq "[.jobs[].steps[] | select(.name == \"$DEPLOY_STEP\") | .conclusion][0] // \"\"" 2>/dev/null)" = "success" ]
}

app_address() {
  gh variable get AZURE_WEBAPP_URL 2>/dev/null
}

azure() { # start|stop
  local id
  say "Asking GitHub to $1 the app on Azure"
  id=$(start_workflow "$AZURE_WORKFLOW" main -f action="$1") || exit 1
  follow_run "$id" || fail "the Azure $1 did not work. Tell Seb."
}

# Builds only put the app on Azure if it is running; start it if it is not answering.
make_sure_app_is_running() {
  local url code
  url=$(app_address)
  [ -n "$url" ] || return 0
  code=$(curl -s -L -o /dev/null -w '%{http_code}' --max-time 20 "$url" 2>/dev/null)
  case "$code" in 2*) return 0 ;; esac
  azure start
}

build() { # branch description
  local id
  say "Building $2 on GitHub (about two minutes)"
  id=$(start_workflow "$LEGACY_WORKFLOW" "$1") || exit 1
  follow_run "$id" || fail "the build of $2 failed. Tell Seb."
  deployed_in "$id" || fail "the build of $2 passed but did not reach Azure. Tell Seb."
}

set_aside_changes() { # command-name
  if [ -n "$(git status --porcelain)" ]; then
    git stash push --include-untracked -m "Set aside by $SCRIPT_NAME $1 on $(date '+%d/%m/%Y %H:%M')" >/dev/null \
      || fail "could not set aside changes left from an earlier run."
    ok "Changes left from an earlier run were set aside (Seb can get them back with 'git stash list')"
  fi
}

# ---- Commands ---------------------------------------------------------------

cmd_check() {
  check_mac
  say "This Mac is ready."
}

cmd_ready() {
  local branch
  check_mac
  say "Getting the code to the starting point"
  set_aside_changes ready
  git switch -q main 2>/dev/null || fail "could not switch to main."
  git pull -q --ff-only 2>/dev/null || fail "could not get the latest code from GitHub."
  ok "On the latest main"

  azure start
  build main "the original app"

  branch="demo/live-$(stamp)"
  git switch -q -c "$branch" || fail "could not start the branch for this run."
  ok "Working on a fresh branch, $branch"

  say "Not automated yet: clearing Cosine's saved memories from earlier runs."
  say "Ready. The app is at: $(app_address)"
  echo "Next: start Cosine in this folder, then run './$SCRIPT_NAME prompt 1' and paste the prompt into Cosine."
}

cmd_prompt() {
  local file text
  case "${1:-}" in
    1) file=prompts/hop-1-joint-keepers.md ;;
    2) fail "the hop 2 prompt is not written yet." ;;
    *) fail "say which prompt: './$SCRIPT_NAME prompt 1'." ;;
  esac
  [ -f "$file" ] || fail "$file is missing."
  text="Carry out the brief in $file"
  printf '%s' "$text" | pbcopy
  say "Copied. Paste this into Cosine:"
  echo "  $text"
}

cmd_prove() {
  local branch head id
  branch=$(git branch --show-current)
  case "$branch" in demo/live-*) ;; *) fail "run './$SCRIPT_NAME ready' first; you are not on this run's branch." ;; esac

  if [ -n "$(git status --porcelain)" ]; then
    { git add -A && git commit -q -m "Changes made by Cosine"; } || fail "could not save Cosine's changes."
    ok "Saved Cosine's changes"
  fi
  [ -n "$(git log --oneline main..HEAD)" ] || fail "Cosine has not changed anything yet."

  make_sure_app_is_running
  say "Sending the change to GitHub"
  git push -q -u origin HEAD || fail "could not send the change to GitHub. Check your GitHub access."
  head=$(git rev-parse HEAD)

  # A push that changes the app starts the build by itself; wait for it, or start it.
  id=$(run_for_commit "$branch" "$head") || id=$(start_workflow "$LEGACY_WORKFLOW" "$branch") || exit 1

  say "Building and checking on GitHub (about two minutes)"
  if follow_run "$id"; then
    if deployed_in "$id"; then
      say "All checks passed and the changed app is on Azure. Open an animal and add a second keeper."
      return 0
    fi
    say "All checks passed, but the changed app did not reach Azure (tell Seb afterwards). Show the screenshots instead."
  else
    say "The build did not pass. Say 'let me show you the one we ran earlier'. Opening the screenshots."
  fi
  open "$FALLBACK_SCREENS" 2>/dev/null
  return 1
}

# Jumping never changes the files on this Mac: the checkpoint is sent to GitHub as a
# new branch and built there.
cmd_jump() {
  local name=${1:-} tag branch sha id
  case "$name" in
    start) make_sure_app_is_running; build main "the original app"; say "The original app is on Azure."; return 0 ;;
    hop1)  tag=checkpoint/hop1 ;;
    *) fail "say which checkpoint: './$SCRIPT_NAME jump start' or './$SCRIPT_NAME jump hop1'." ;;
  esac
  git fetch -q --force origin "refs/tags/$tag:refs/tags/$tag" 2>/dev/null || fail "the '$name' checkpoint has not been chosen yet."
  sha=$(git rev-parse "refs/tags/$tag^{commit}") || fail "the '$name' checkpoint could not be read."
  make_sure_app_is_running
  branch="demo/jump-$name-$(stamp)"
  git push -q origin "$sha:refs/heads/$branch" || fail "could not send the checkpoint to GitHub."
  say "Building the '$name' checkpoint on GitHub (about two minutes)"
  id=$(run_for_commit "$branch" "$sha") || id=$(start_workflow "$LEGACY_WORKFLOW" "$branch") || exit 1
  follow_run "$id" || fail "the checkpoint build failed. Tell Seb."
  deployed_in "$id" || fail "the checkpoint build passed but did not reach Azure. Tell Seb."
  say "The '$name' checkpoint is on Azure."
}

cmd_reset() {
  check_mac
  set_aside_changes reset
  git switch -q main || fail "could not switch to main."
  azure stop
  say "Done. The Azure app is stopped. './$SCRIPT_NAME ready' puts the original app back before the next demo."
}

case "${1:-}" in
  check)  cmd_check ;;
  ready)  cmd_ready ;;
  prompt) cmd_prompt "${2:-}" ;;
  prove)  cmd_prove ;;
  jump)   cmd_jump "${2:-}" ;;
  reset)  cmd_reset ;;
  *) sed -n '2,12p' "$SCRIPT_NAME" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
