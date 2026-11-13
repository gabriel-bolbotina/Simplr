# 03 · User stories

Format: **As a** user, **I want** … **so that** …, followed by acceptance criteria (AC).
Each story becomes one GitHub issue (see [Board](07-board.md)). IDs are stable — reference them in commits, e.g. `G-1: glass thumb`.

Legend: **M**ust · **S**hould · **C**ould

---

## M0 · Foundation

**F-1 · Mac target** (M, chore)
I want the project to run as a native macOS 26+ app so that I can use Liquid Glass and Mac APIs.
- AC: current WIP committed; target is macOS 26+; app launches; old iOS-only code removed or adapted.

**F-2 · Data model v2** (M)
I want boards, tasks, categories and shortcuts stored locally so that my data survives restarts.
- AC: SwiftData models `Board`, `TaskItem`, `Category`, `Shortcut` (see [Decisions](05-decisions.md#d-005--data-model-v2)); seed data for previews; unit tests for status/progress rules.

**F-3 · App shell** (M)
I want a sidebar + content layout with a glass toolbar so that the app feels like a native Mac app.
- AC: `NavigationSplitView` with boards in sidebar; toolbar with view switcher (List / Kanban) and "+"; window remembers size.

## M1 · Boards & views

**B-1 · Manage boards** (M)
I want to create, rename, reorder and delete boards so that I can separate areas of life.
- AC: "+" in sidebar; inline rename; delete asks for confirmation; empty state for no boards.

**B-2 · Create & edit tasks** (M)
I want to create and edit a task (title, notes, due date, priority, category) so that I can capture what I need to do.
- AC: ⌘N creates a task in the current board; editing via inspector or sheet; title required; delete with ⌫ + confirm.

**B-3 · List view** (M)
I want to see a board's tasks as a list so that I can scan them quickly.
- AC: grouped by status; shows title, category tint, progress, due date, shortcut icons.

**B-4 · Kanban view** (M)
I want to see the same board as kanban columns so that I can see flow at a glance.
- AC: To Do / In Progress / Done columns; switching views keeps selection; columns scroll independently.

**B-5 · Drag between columns** (M)
I want to drag a card to another column so that changing status is one gesture.
- AC: drop updates status; moving to Done sets progress to 100 %; moving out of Done resets to the previous progress or 0 %; order persists.

## M2 · Glass slider & categories

**G-1 · Glass thumb** (M) — *the showpiece*
I want a Liquid Glass slider thumb that stretches and morphs as I drag so that updating progress feels tactile.
- AC: thumb uses `glassEffect`; stretches along drag velocity and settles with a spring; works with mouse and trackpad; accessible via keyboard (← →) and VoiceOver as a slider.

**G-2 · Tinted glass fill** (M)
I want the card to fill with tinted glass as progress grows so that I can read progress without numbers.
- AC: fill width = progress; tint = category colour; looks good in light & dark mode.

**G-3 · Haptic ticks** (M)
I want a trackpad haptic at 25 / 50 / 75 % so that I can *feel* milestones.
- AC: `NSHapticFeedbackManager` fires once per threshold crossing (both directions); no haptics on mouse.

**G-4 · Auto-Done** (M)
I want a task to move to Done when I drag it to 100 % so that progress and status never disagree.
- AC: 100 % → Done (with completion effect, see H-2); >0 % → In Progress; 0 % → To Do. Rules covered by unit tests.

**G-5 · Categories, colours & patterns** (M; patterns S)
I want to give tasks a category with a colour (and optionally a pattern) so that boards look organised and personal.
- AC: CRUD categories; colour picker; tint used by G-2; *(Should)* pattern picker — stripes, dots, waves — rendered inside the glass fill.

## M3 · Shortcuts

**S-1 · Website shortcut** (M)
I want to attach a URL to a task and see the site's favicon so that I can jump to where the work happens.
- AC: paste/drop a URL; favicon fetched via LinkPresentation (fallback: SF Symbol `globe`); icon cached in the model.

**S-2 · App shortcut** (M)
I want to attach a Mac app to a task and see its real icon so that I can launch it from the task.
- AC: pick via open panel or drag an app from Finder/Dock; stores bundle ID; icon from `NSWorkspace`.

**S-3 · Open shortcut** (M)
I want to click a shortcut icon on a card to open it so that a task is one click away from action.
- AC: URL → default browser; app → launches/activates; missing app shows a gentle error; works in list, kanban and menu bar.

## M4 · Mac integration

**M-1 · Menu bar quick-view** (M)
I want a menu bar icon showing today's and in-progress tasks so that I can check and update without opening the window.
- AC: `MenuBarExtra` (window style); progress slider works there; "Open Simplr" button; shows current streak.

**M-2 · Global quick-add** (M)
I want a global hotkey that opens a quick-add panel from anywhere so that I can capture a task in two seconds.
- AC: default ⌥⌘Space (configurable in Settings); floating glass panel; Enter saves to the default board; Esc dismisses.

## M5 · Hooked & ship

**H-1 · Streak** (M)
I want to see how many days in a row I've completed at least one task so that I'm motivated to keep going.
- AC: streak computed from completion dates; shown in sidebar and menu bar; a missed day resets it; timezone-safe.

**H-2 · Completion effect** (M)
I want a visually satisfying moment when a task hits Done so that finishing feels rewarding.
- AC: glass "ripple/burst" in category colour + haptic; respects Reduce Motion; < 1 s and never blocks input.

**R-1 · Showcase README** (S)
I want a README with a GIF, feature list and links to these docs so that visitors understand the project in 30 s.

**R-2 · Release build** (S)
I want a downloadable `.app` on GitHub Releases so that people can try it without Xcode.
- AC: archived build, zipped, attached to tag `v1.0.0`; release notes generated from closed issues.
