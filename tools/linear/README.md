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
- One-time per person: Linear → Settings → Account → *Connected accounts* → GitHub, and *Preferences → Git branch format* = `planning/{issue-identifier}-{issue-title}`.
- Every issue gets one assignee and one Area label.

### Linking PRs to issues (automatic, via Linear's GitHub integration)
A PR is attached to issue `CS-12` when `CS-12` appears in any of:
- **the branch name** — easiest: open the issue in Linear and press `Ctrl/Cmd+Shift+.` to copy a ready branch name (e.g. `planning/cs-12-ecb-class-diagram`);
- **the PR title or description** (the PR template pre-fills `Fixes CS-`):
  - `Fixes CS-12` / `Closes CS-12` — link, and merging moves the issue to **Done**;
  - `Part of CS-12` / `Ref CS-12` — link only, the issue stays open;
- **commit messages** containing `CS-12` also show on the issue.

Status follows the PR: draft or opened → **In Progress**, review requested → **In Review**, merged → **Done**.
