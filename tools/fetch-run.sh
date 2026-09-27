#!/bin/sh
# Brings down the results of the latest successful 'Legacy app' run on GitHub:
# the golden master results into golden/results and the demo screenshots into demo/screens/legacy.
# Run it from the top of the repository. Needs the GitHub CLI (gh), logged in.
set -e

run=$(gh run list --workflow legacy.yml --status success --limit 1 --json databaseId --jq '.[0].databaseId')
if [ -z "$run" ]; then
  echo "No successful run of the Legacy app workflow found."
  exit 1
fi
echo "Fetching run $run"

tmp=$(mktemp -d)
gh run download "$run" --name golden-results --dir "$tmp/golden"
gh run download "$run" --name legacy-screens --dir "$tmp/screens"

mkdir -p golden/results demo/screens/legacy
cp "$tmp"/golden/*.json golden/results/
cp "$tmp"/screens/*.png demo/screens/legacy/
rm -rf "$tmp"

echo "Golden results: $(ls golden/results/*.json | wc -l | tr -d ' ') files in golden/results"
echo "Screenshots:    $(ls demo/screens/legacy/*.png | wc -l | tr -d ' ') files in demo/screens/legacy"
echo "Review the changes with 'git status', then commit them."
