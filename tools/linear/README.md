# Linear setup

`setup.sh` configures the CrysisSync Linear workspace: team **CrysisSync (`CS`)**, 1-week cycles (sprints) running Sunday to Saturday, auto-archive after 1 month, an **In Review** workflow state, and an **Area** label group (`use-case`, `requirements`, `diagram`, `spec`, `tests`, `docs`). It is safe to re-run; it only adds what is missing.

## Run it
1. Linear → Settings → **Security & access → Personal API keys** → *New API key* (Full access, all teams). Copy it.
2. Put it in the repo-root `.env` (gitignored; template in `.env.example`):
   ```bash
   printf 'LINEAR_API_KEY=%s\n' "$(wl-paste -n)" > .env && chmod 600 .env   # Wayland; on macOS use pbpaste
   ```
3. `bash tools/linear/setup.sh` (needs `curl` and `jq`).

Never commit `.env`. Revoke the key in Linear when you no longer need it.

## Team conventions
- One-time per person: Linear → Settings → Account → *Connected accounts* → GitHub.
- Every issue gets one assignee and one Area label.

### Branch names
Linear suggests a branch name for every issue: open it and press `Ctrl/Cmd+Shift+.`. The format is `<your-username>/<issue-id>-<issue-title>`, e.g. `dima/cs-12-ecb-class-diagram` (workspace-wide setting, Linear's default — nothing to configure).

**Several people on one issue:**
1. **Preferred — split it into sub-issues, one person each** (open the issue → *Add sub-issue*). Each person copies their own sub-issue's branch (`tomer/cs-60-…`, `itay/cs-61-…`), each PR links to its sub-issue, and the parent shows overall progress. This also gives every task in `SPRINT_BACKLOG.md` exactly one owner and estimate.
2. **Pair work on one branch:** whoever starts creates the branch; the others commit to it. The name only shows who started it — each person's commits still count under their own GitHub account.
3. **One issue, several PRs:** use `Part of CS-12` in every PR except the last, which uses `Fixes CS-12`, so the issue reaches Done only when the final piece is merged.

### Linking PRs to issues (automatic, via Linear's GitHub integration)
A PR is attached to issue `CS-12` when `CS-12` appears in any of:
- **the branch name** — easiest: open the issue in Linear and press `Ctrl/Cmd+Shift+.` to copy a ready branch name (e.g. `dima/cs-12-ecb-class-diagram`);
- **the PR title or description** (the PR template pre-fills `Fixes CS-`):
  - `Fixes CS-12` / `Closes CS-12` — link, and merging moves the issue to **Done**;
  - `Part of CS-12` / `Ref CS-12` — link only, the issue stays open;
- **commit messages** containing `CS-12` also show on the issue.

Status follows the PR: draft or opened → **In Progress**, review requested → **In Review**, merged → **Done**.
