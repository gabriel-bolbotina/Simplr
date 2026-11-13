# 05 · Decisions

A lightweight decision log (ADR-style). Newest at the bottom. Never edit a past decision; supersede it with a new one.

| ID | Date | Decision | Status |
|---|---|---|---|
| D-001 | 2026-11-13 | macOS first (26+), iOS later | Accepted |
| D-002 | 2026-11-13 | List and Kanban are two views of the same board data | Accepted |
| D-003 | 2026-11-13 | Shortcuts attach to tasks; URLs + apps in v1, files/folders in v2 | Accepted |
| D-004 | 2026-11-13 | Progress drives status | Accepted |
| D-005 | 2026-11-13 | Data model v2 | Accepted |
| D-006 | 2026-11-13 | Streak is derived, not stored | Accepted |
| D-007 | 2026-11-13 | Use `KeyboardShortcuts` package for the global hotkey | Proposed |
| D-008 | 2026-11-13 | Docs in repo, work tracked on a GitHub Project | Accepted |
| D-009 | 2026-11-13 | P0–P3 priority + T-shirt size on the board | Accepted |
| D-010 | 2026-11-13 | Clarify D-004 for kanban moves; CloudKit-ready model | Accepted |
| D-011 | 2026-11-13 | Card shade instead of a progress glass fill; solid knob that turns into a glass lens | Accepted |

---

### D-001 · macOS first

**Context:** The existing code targets iOS 17.5. The appeal of the app is Liquid Glass + Mac integration (menu bar, hotkey).
**Decision:** Retarget to macOS 26+. Keep views free of AppKit where possible so iOS (v2) is a port, not a rewrite.
**Consequences:** Mac-only APIs (`MenuBarExtra`, `NSWorkspace`, `NSHapticFeedbackManager`) live behind small wrappers.

### D-002 · Two views, one data set

**Context:** Lists and kanban were requested. They could be separate object types or two views.
**Decision:** A `Board` owns tasks; the user switches between List and Kanban views of the same board.
**Consequences:** One source of truth; status is the kanban column. View choice is remembered per board.

### D-003 · Shortcuts belong to tasks

**Context:** The "sticky notes that open an app" idea. Could be per task, per board or global.
**Decision:** A task has 0…n shortcuts. v1: URL and app. v2: files/folders (needs security-scoped bookmarks). Later:
integrate with the target app's API/MCP server instead of just opening it.
**Consequences:** `Shortcut` is its own model with a `kind` so new kinds can be added without migrations of `TaskItem`.

### D-004 · Progress drives status

**Context:** A slider for progress and kanban columns for status can contradict each other.
**Decision:** One rule set, enforced in the model: `0 % → To Do`, `1–99 % → In Progress`, `100 % → Done`. Dragging a card
to Done sets 100 %; dragging out of Done restores the last non-100 value (or 0 %).
**Consequences:** No "Done but 40 %" states. Fixed three columns for v1; custom columns are a *Could*.

### D-005 · Data model v2

```
Board      id, name, symbol, sortOrder, preferredView(list|kanban)   1 ── * TaskItem
TaskItem   id, title, notes, dueDate?, priority, progress, status,
           sortOrder, createdAt, completedAt?                          * ── 0..1 Category
                                                                       1 ── * Shortcut
Category   id, name, colorHex, pattern(none|stripes|dots|waves)
Shortcut   id, kind(url|app), target(URL string | bundle ID), title, iconData?
```

**Consequences:** Replaces `TaskObject` (`status: Bool`). `TaskItem` avoids clashing with Swift Concurrency's `Task`.
No migration needed — there's no real user data yet.

### D-006 · Streak is derived

**Decision:** A day counts if ≥1 task has `completedAt` on that calendar day (user's current calendar/timezone). Streak =
consecutive counted days ending today or yesterday. Computed, not stored.
**Consequences:** No sync/consistency bugs; un-completing a task can lower the streak (acceptable, it's honest).

### D-007 · Global hotkey via `KeyboardShortcuts` (proposed)

**Context:** Global hotkeys need Carbon `RegisterEventHotKey` (works in the sandbox) or an event tap (needs Accessibility).
**Options:** (a) [sindresorhus/KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) — includes a recorder UI;
(b) hand-roll the Carbon wrapper — more learning, more code.
**Leaning:** (a), and read its source as the learning exercise. Decide at the start of M4.

### D-008 · Docs in repo, work on a GitHub Project

**Decision:** Product docs live in `docs/` as Markdown (versioned with the code, rendered by GitHub, Mermaid charts
included). Execution is tracked on a public GitHub Project; one issue per user story.

### D-009 · P0–P3 priority + T-shirt size

**Context:** MoSCoW says what's in the release, not what to work on next. Options considered: P0–P3 + Size, RICE, ICE.
**Decision:** Two project fields — Priority (P0–P3) and Size (XS–XL). RICE/ICE rejected: with one user, *Reach* is
meaningless and numeric scores would be false precision. See [Board](07-board.md#prioritisation).
**Consequences:** Simple to sort and maintain; XL items must be split before work starts.

### D-010 · Kanban moves & a CloudKit-ready model

**Context:** Implementing F-2 surfaced a gap in D-004: dragging a card from To Do to In Progress leaves it at 0 %.
**Decision:**
- The slider path stays strict (0 % → To Do, 1–99 % → In Progress, 100 % → Done).
- The kanban path may put a task In Progress at 0 % ("started, no progress yet"). To Do always means 0 %, Done always 100 %.
- Leaving Done restores `progressBeforeDone`.
- All rules live in `TaskItem.setProgress(_:)` and `TaskItem.move(to:)`; views never set `progress`/`status` directly.
- Every model property has a default and every relationship is optional, so iCloud sync (v1.2) won't need a migration.

### D-011 · Card shade instead of glass fill; knob → glass lens

**Context:** Hands-on review of M2. The progress-width glass fill (G-2) competed with the title, priority and slider,
cluttering the visual hierarchy. The clear glass thumb (G-1) was hard to see, because glass over a thin track has
almost nothing to refract.
**Decision:**
- Cards get a soft, static shade in the category colour (patterns as a faint texture). The slider is the single
  progress indicator; kanban cards keep a thin progress bar.
- The thumb behaves like macOS system sliders: a solid white knob at rest that becomes a larger Liquid Glass lens
  while held, with stronger velocity stretch. The % bubble appears just after the lens so it visibly grows out of it.
**Consequences:** Glass is reserved for the interaction itself rather than for static content, as Apple's guidelines recommend.
Supersedes the fill part of G-2.
