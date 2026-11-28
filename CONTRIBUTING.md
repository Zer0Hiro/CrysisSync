# Contributing to CrysisSync

We track work in **Linear** (team `CS`, weekly sprints Sunday–Saturday). Never commit straight to `master`; every change goes through a pull request.

## Once per person
- Linear → Settings → Account → *Connected accounts* → **GitHub**, so your PRs show under your name.

## Issues
- Every issue has **one assignee** and **one Area label** (`use-case`, `requirements`, `diagram`, `spec`, `tests`, `docs`, `gui`, `server`, `database`, `network`).

## Branch names
Open the issue in Linear and press `Ctrl/Cmd+Shift+.` to copy its branch name: `<your-username>/<issue-id>-<issue-title>`, e.g. `dima/cs-12-ecb-class-diagram`. Start a new branch for every issue; don't push to a branch whose PR is already merged.

**Several people on one issue:**
1. **Preferred — split it into sub-issues, one person each** (open the issue → *Add sub-issue*). Each person copies their own sub-issue's branch (`tomer/cs-60-…`, `itay/cs-61-…`); the parent shows overall progress. This also gives every task in `SPRINT_BACKLOG.md` exactly one owner and estimate.
2. **Pair work on one branch:** whoever starts creates the branch; the others commit to it. Each person's commits still count under their own GitHub account.
3. **One issue, several PRs:** write `Part of CS-12` in every PR except the last, which uses `Fixes CS-12`, so the issue reaches Done only when the final piece is merged.

## Pull requests and Linear
A PR is attached to issue `CS-12` automatically when `CS-12` appears in:
- **the branch name** (the Linear-copied name already contains it);
- **the PR title or description** — the PR template pre-fills `Fixes CS-`:
  - `Fixes CS-12` / `Closes CS-12` — link, and merging moves the issue to **Done**;
  - `Part of CS-12` / `Ref CS-12` — link only, the issue stays open;
- **commit messages** containing `CS-12`.

The issue status follows the PR: draft or opened → **In Progress**, review requested → **In Review**, merged → **Done**.

Discord: `#github` shows pushes, PRs and reviews; `#linear` shows new issues, status changes and comments. The Linear/Discord setup scripts live in a separate private repo (LinearConfig), not here.

## Use-case artifacts
If you change the use-case model, keep all four in sync: `UseCase/G11_Assignment1.vpp`, `UseCase/useCase.puml`, `UseCase/CrysisSync-Use-Case-Diagram.mmd`, `UseCase/UseCaseSpecifications.md`.
