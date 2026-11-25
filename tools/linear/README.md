# Linear setup

`setup.sh` configures the CrysisSync Linear workspace: team **CrysisSync (`CS`)**, 2-week cycles (sprints) starting Sunday, auto-archive after 1 month, an **In Review** workflow state, and an **Area** label group (`use-case`, `requirements`, `diagram`, `spec`, `tests`, `docs`). It is safe to re-run; it only adds what is missing.

## Run it
1. Linear → Settings → **Security & access → Personal API keys** → *New API key* (Full access, all teams). Copy it.
2. Put it in the repo-root `.env` (gitignored; template in `.env.example`):
   ```bash
   printf 'LINEAR_API_KEY=%s\n' "$(wl-paste -n)" > .env && chmod 600 .env   # Wayland; on macOS use pbpaste
   ```
3. `bash tools/linear/setup.sh` (needs `curl` and `jq`).

Never commit `.env`. Revoke the key in Linear when you no longer need it.

## Team conventions
- Branches: Linear → Settings → Account → Preferences → *Git branch format* = `planning/{issue-identifier}-{issue-title}`, then copy the branch name from an issue (`Ctrl/Cmd+Shift+.`).
- PRs: put `Fixes CS-12` in the PR description to link and auto-close the issue.
- Every issue gets one assignee and one Area label.
