#!/usr/bin/env bash
# Requires a running app with the standard seed and agent-browser + Chrome installed.
set -euo pipefail

browser="${AGENT_BROWSER:-agent-browser}"
session="${BROWSER_SESSION:-dev-ui-regression}"
base_url="${BASE_URL:-http://localhost:5173}"
ab() { "$browser" --session "$session" "$@"; }
trap 'ab close >/dev/null 2>&1 || true' EXIT

list='form[action^="/api/switch-user"]'
closed='!document.querySelector("form[action^=\"/api/switch-user\"]")'
open_selector() {
  # The server-rendered trigger can precede hydration on the first visit.
  for _ in {1..20}; do
    if [[ "$(ab eval "Boolean(document.querySelector('$list'))")" == "true" ]]; then
      return
    fi
    ab find role button click --name "Switch user" >/dev/null
    sleep 0.1
  done
  echo "FAIL: user selector did not open" >&2
  exit 1
}
assert_closed() { ab wait --fn "$closed" --timeout 3000 >/dev/null; }
shot() {
  if [[ -n "${EVIDENCE_DIR:-}" ]]; then
    mkdir -p "$EVIDENCE_DIR"
    ab screenshot "$EVIDENCE_DIR/$1.png" >/dev/null
  fi
}

ab open "$base_url/courses" >/dev/null
ab wait --text "Browse Courses" >/dev/null
open_selector
ab find role button click --name "Alex Rivera Admin" >/dev/null
assert_closed
ab wait --fn 'document.querySelector(".fixed.bottom-4.right-4").innerText.includes("Alex Rivera")' >/dev/null
open_selector
ab find role button click --name "Emma Wilson Student" >/dev/null
assert_closed
ab wait --fn 'document.querySelector(".fixed.bottom-4.right-4").innerText.includes("Emma Wilson")' >/dev/null
shot after-selection
printf 'PASS: selecting a user closes the list and updates the session\n'

open_selector
ab find role heading click --name "Browse Courses" --exact >/dev/null
assert_closed
shot after-outside
printf 'PASS: outside click dismisses the list\n'

open_selector
ab press Escape >/dev/null
assert_closed
ab eval 'if (document.activeElement?.textContent.trim() !== "Switch user") throw new Error("Focus was not restored to the trigger")' >/dev/null
printf 'PASS: Escape dismisses the list and restores trigger focus\n'

open_selector
ab find role button click --name "Switch user" >/dev/null
assert_closed
printf 'PASS: trigger toggles the list closed\n'

ab find role button click --name "Minimize DevUI" >/dev/null
assert_closed
ab find role button click --name "DevUI" --exact >/dev/null
assert_closed
printf 'PASS: minimizing and restoring DevUI does not reopen the list\n'

errors="$(ab errors)"
if [[ -n "$errors" ]]; then
  printf 'FAIL: browser errors: %s\n' "$errors" >&2
  exit 1
fi
printf 'PASS: no browser errors\n'
