# 07 · Board

Work is tracked on a public **GitHub Project** linked to this repo. One issue per user story in
[User stories](03-user-stories.md).

## Structure

| Thing | Setup |
|---|---|
| **Milestones** (repo) | `M0 Foundation` … `M5 Hooked & ship` — one per roadmap milestone |
| **Labels** | Area: `area:foundation`, `area:boards`, `area:glass`, `area:shortcuts`, `area:mac`, `area:hooked`, `area:showcase` · Priority: `must`, `should`, `could` · Type: `feature`, `chore`, `docs` |
| **Status** (project field) | Todo → In Progress → Done |
| **Priority** (project field) | P0 Blocker · P1 High · P2 Medium · P3 Low — see below |
| **Size** (project field) | XS · S · M · L · XL — see below |
| **Views** | **Board** (by Status) · **Roadmap** (by Milestone) · **Table** (all fields) · **Insights** chart |

## Prioritisation

Two layers, two questions:

- **MoSCoW label** (`must` / `should` / `could`): *is it in the release?* Set during scoping, rarely changes.
- **Priority field**: *what do I pick up next?* Re-checked at the start of every milestone.

| Priority | Meaning | Rule of thumb |
|---|---|---|
| **P0 Blocker** | Other work can't start without it | Do first, never more than one P0 in progress |
| **P1 High** | Core MVP value — the reason the milestone exists | Bulk of each milestone |
| **P2 Medium** | In the MVP, but can slip to the end of the milestone | Pick up when P0/P1 are done or blocked |
| **P3 Low** | Polish / showcase | Last; first to cut |

| Size | Effort (at ~5 h/week) | |
|---|---|---|
| **XS** | < 1 h | a single sitting |
| **S** | 1–2 h | one session |
| **M** | 2–5 h | about a week |
| **L** | 5–10 h | about two weeks — consider splitting |
| **XL** | > 10 h | must be split into sub-issues before starting |

**Picking the next ticket:** current milestone → highest Priority → smallest Size. Board and table views sort by
`Milestone ↑, Priority ↑, Size ↑`.

**Triage of new ideas:** every new issue gets a MoSCoW label, a Priority and a Size before it leaves *Todo*. A new idea
defaults to `could` + P3 and must argue its way up.

## Charts

- **Docs:** [Roadmap](04-roadmap.md) has Mermaid pie charts (scope by area, effort by milestone, status). GitHub renders them.
- **Live:** in the Project, go to *Insights → New chart*: e.g. a stacked bar of items grouped by **Milestone**, sliced by **Status**.
  That chart updates itself as issues move.

## Working agreement

- **WIP limit:** max 2 items In Progress.
- **Branch per story:** `g-1-glass-thumb`; PR title starts with the story ID; `Closes #<issue>` in the PR body.
- **Definition of Done:** acceptance criteria met · works in light & dark mode · no new warnings · demo screenshot/GIF in the PR.
- **End of milestone:** close the milestone, update the status pie in the roadmap, write a 3-line retro in
  [Learning goals](06-learning-goals.md).

## Seeding the board

`scripts/seed-board.sh` creates the labels, milestones, the 22 story issues and the project. It needs the `project` scope:

```sh
gh auth refresh -s project
./scripts/seed-board.sh            # dry run: prints what it would do
./scripts/seed-board.sh --apply    # actually creates everything
```
