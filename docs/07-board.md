# 07 · Board

Work is tracked on a public **GitHub Project** linked to this repo. One issue per user story in
[User stories](03-user-stories.md).

## Structure

| Thing | Setup |
|---|---|
| **Milestones** (repo) | `M0 Foundation` … `M5 Hooked & ship` — one per roadmap milestone |
| **Labels** | Area: `area:foundation`, `area:boards`, `area:glass`, `area:shortcuts`, `area:mac`, `area:hooked`, `area:showcase` · Priority: `must`, `should`, `could` · Type: `feature`, `chore`, `docs` |
| **Status** (project field) | Todo → In Progress → Done |
| **Views** | **Board** (by Status) · **Roadmap** (by Milestone) · **Table** (all fields) · **Insights** chart |

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
