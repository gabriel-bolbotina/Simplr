#!/usr/bin/env bash
# Seeds the GitHub repo with labels, milestones, one issue per user story, and a Project board.
# Dry run by default; pass --apply to create things. Safe to re-run: existing items are skipped.
# Requires: gh with the `project` scope (gh auth refresh -s project).
set -euo pipefail

REPO="gabriel-bolbotina/Simplr"
OWNER="gabriel-bolbotina"
PROJECT_TITLE="Simplr Roadmap"
DOCS="https://github.com/$REPO/blob/main/docs"
APPLY=false
[[ "${1:-}" == "--apply" ]] && APPLY=true

run() { if $APPLY; then "$@"; else echo "[dry-run] $*"; fi; }

# ---- Labels: name|color|description
LABELS=$(cat <<'EOF'
area:foundation|5319e7|Project setup, data model, app shell
area:boards|1d76db|Boards, list & kanban views
area:glass|0e8a16|Liquid Glass slider, categories, patterns
area:shortcuts|fbca04|App & website shortcuts on tasks
area:mac|c5def5|Menu bar, hotkey, macOS integration
area:hooked|d93f0b|Streaks & satisfying effects
area:showcase|bfdadc|README, release, portfolio
must|b60205|MoSCoW: Must
should|e99695|MoSCoW: Should
could|f9d0c4|MoSCoW: Could
feature|a2eeef|New capability
chore|cfd3d7|Setup / maintenance
docs|0075ca|Documentation
EOF
)

# ---- Milestones: title|description
MILESTONES=$(cat <<'EOF'
M0 Foundation|Mac app skeleton on the new data model
M1 Boards & views|Boards with List and Kanban views of the same tasks
M2 Glass slider|Liquid Glass progress slider, haptics, auto-Done, categories
M3 Shortcuts|Attach apps and websites to tasks
M4 Mac integration|Menu bar quick-view and global quick-add hotkey
M5 Hooked & ship|Streaks, completion effect, README, v1.0 release
EOF
)

# ---- Issues: milestone|labels|title|summary|anchor
ISSUES=$(cat <<'EOF'
M0 Foundation|area:foundation,must,chore|F-1 · Retarget to macOS 26+|Commit WIP and turn the iOS project into a native macOS 26+ app.|m0--foundation
M0 Foundation|area:foundation,must,feature|F-2 · Data model v2|SwiftData models Board, TaskItem, Category, Shortcut (D-005) with tests for status/progress rules.|m0--foundation
M0 Foundation|area:foundation,must,feature|F-3 · App shell with sidebar & glass toolbar|NavigationSplitView, boards in sidebar, List/Kanban switcher in a glass toolbar.|m0--foundation
M1 Boards & views|area:boards,must,feature|B-1 · Manage boards|Create, rename, reorder and delete boards in the sidebar.|m1--boards--views
M1 Boards & views|area:boards,must,feature|B-2 · Create & edit tasks|Title, notes, due date, priority, category; ⌘N to create.|m1--boards--views
M1 Boards & views|area:boards,must,feature|B-3 · List view|Board tasks as a list grouped by status.|m1--boards--views
M1 Boards & views|area:boards,must,feature|B-4 · Kanban view|Same board as To Do / In Progress / Done columns.|m1--boards--views
M1 Boards & views|area:boards,must,feature|B-5 · Drag cards between columns|Drop changes status and keeps progress consistent (D-004).|m1--boards--views
M2 Glass slider|area:glass,must,feature|G-1 · Morphing glass slider thumb|The showpiece: a Liquid Glass thumb that stretches and morphs while dragging.|m2--glass-slider--categories
M2 Glass slider|area:glass,must,feature|G-2 · Tinted glass card fill|Card fills with category-tinted glass as progress grows.|m2--glass-slider--categories
M2 Glass slider|area:glass,must,feature|G-3 · Haptic ticks at 25/50/75%|Trackpad haptic feedback when crossing progress thresholds.|m2--glass-slider--categories
M2 Glass slider|area:glass,must,feature|G-4 · Auto-Done at 100%|Progress drives status: 0% To Do, 1–99% In Progress, 100% Done.|m2--glass-slider--categories
M2 Glass slider|area:glass,must,feature|G-5 · Categories, colours & patterns|Category colour tints the glass; patterns (stripes/dots/waves) are a Should.|m2--glass-slider--categories
M3 Shortcuts|area:shortcuts,must,feature|S-1 · Website shortcut with favicon|Attach a URL to a task and show the site's favicon.|m3--shortcuts
M3 Shortcuts|area:shortcuts,must,feature|S-2 · App shortcut with icon|Attach a Mac app to a task and show its real icon.|m3--shortcuts
M3 Shortcuts|area:shortcuts,must,feature|S-3 · Open shortcut in one click|Clicking a shortcut opens the site or launches the app.|m3--shortcuts
M4 Mac integration|area:mac,must,feature|M-1 · Menu bar quick-view|MenuBarExtra with today's and in-progress tasks, slider and streak.|m4--mac-integration
M4 Mac integration|area:mac,must,feature|M-2 · Global quick-add hotkey|⌥⌘Space opens a floating glass panel to add a task from anywhere.|m4--mac-integration
M5 Hooked & ship|area:hooked,must,feature|H-1 · Daily streak|Consecutive days with ≥1 completed task, shown in sidebar and menu bar.|m5--hooked--ship
M5 Hooked & ship|area:hooked,must,feature|H-2 · Satisfying completion effect|Glass burst in category colour + haptic when a task hits Done.|m5--hooked--ship
M5 Hooked & ship|area:showcase,should,docs|R-1 · Showcase README|README with GIF, features and links to product docs.|m5--hooked--ship
M5 Hooked & ship|area:showcase,should,chore|R-2 · v1.0.0 release build|Archived .app attached to a GitHub Release with notes.|m5--hooked--ship
EOF
)

echo "== Labels"
existing_labels=$(gh label list -R "$REPO" --limit 200 --json name -q '.[].name')
while IFS='|' read -r name color desc; do
  grep -qxF "$name" <<<"$existing_labels" && { echo "skip label $name"; continue; }
  run gh label create "$name" -R "$REPO" --color "$color" --description "$desc"
done <<<"$LABELS"

echo "== Milestones"
existing_ms=$(gh api "repos/$REPO/milestones?state=all&per_page=100" -q '.[].title')
while IFS='|' read -r title desc; do
  grep -qxF "$title" <<<"$existing_ms" && { echo "skip milestone $title"; continue; }
  run gh api "repos/$REPO/milestones" -f title="$title" -f description="$desc" --silent
done <<<"$MILESTONES"

echo "== Issues"
existing_issues=$(gh issue list -R "$REPO" --state all --limit 500 --json title -q '.[].title')
while IFS='|' read -r milestone labels title summary anchor; do
  grep -qxF "$title" <<<"$existing_issues" && { echo "skip issue $title"; continue; }
  body="$summary

**Acceptance criteria & context:** [docs/03-user-stories.md]($DOCS/03-user-stories.md#$anchor)"
  if $APPLY; then
    url=$(gh issue create -R "$REPO" --title "$title" --body "$body" --label "$labels" --milestone "$milestone")
    echo "created $url"
  else
    echo "[dry-run] issue \"$title\" [$labels] → $milestone"
  fi
done <<<"$ISSUES"

echo "== Project"
if ! gh auth status 2>&1 | grep -q "'project'"; then
  echo "skip project: token lacks the 'project' scope (run: gh auth refresh -s project, then re-run)"
  exit 0
fi
project_number=$(gh project list --owner "$OWNER" --format json -q ".projects[] | select(.title==\"$PROJECT_TITLE\") | .number" 2>/dev/null || true)
if [[ -z "$project_number" ]]; then
  if $APPLY; then
    project_number=$(gh project create --owner "$OWNER" --title "$PROJECT_TITLE" --format json -q '.number')
    gh project link "$project_number" --owner "$OWNER" --repo "$REPO"
    gh project edit "$project_number" --owner "$OWNER" --visibility PUBLIC \
      --description "Product roadmap for Simplr — see docs/ in the repo"
  else
    echo "[dry-run] gh project create --owner $OWNER --title \"$PROJECT_TITLE\" (+ link to repo, make public)"
  fi
else
  echo "skip project #$project_number"
fi


echo "== Add issues to project"
if $APPLY && [[ -n "$project_number" ]]; then
  while IFS='|' read -r _ _ title _ _; do
    url=$(gh issue list -R "$REPO" --state all --search "\"$title\" in:title" --json title,url -q ".[] | select(.title==\"$title\") | .url")
    [[ -n "$url" ]] && gh project item-add "$project_number" --owner "$OWNER" --url "$url" >/dev/null && echo "added $title"
  done <<<"$ISSUES"
else
  echo "[dry-run] add all story issues to \"$PROJECT_TITLE\""
fi

echo "Done. Next: in the Project UI add Board / Roadmap / Table views and an Insights chart (see docs/07-board.md)."
