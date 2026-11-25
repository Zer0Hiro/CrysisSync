# Discord notifications

| Channel    | What it gets                                                     | How                                                                 |
|------------|------------------------------------------------------------------|---------------------------------------------------------------------|
| `#github`  | pushes, pull requests, PR reviews and review comments            | GitHub repo webhook → Discord's built-in GitHub endpoint (`/github`) |
| `#linear`  | issue created, issue status changed, comment added (team `CS`)   | Linear webhook → Cloudflare Worker (`worker.js`) → Discord          |

The worker lives at `https://crysissync-linear-discord.zer0hiro.workers.dev`. It accepts only requests signed with the Linear webhook's secret (`Linear-Signature`, HMAC-SHA256), rejects deliveries older than 60 s, and never pings `@everyone`.

Everything is already set up; teammates don't need to run anything.

## Re-running / changing it (repo admin + Cloudflare account owner)
1. `.env` (gitignored, see `.env.example`) needs `LINEAR_API_KEY`, `DISCORD_GITHUB_WEBHOOK`, `DISCORD_LINEAR_WEBHOOK`. `LINEAR_WEBHOOK_SECRET` is generated on the first run.
2. Once: `npx wrangler@4.156.0 login`.
3. `bash tools/discord/setup.sh` — safe to re-run; it only creates what is missing and re-syncs the worker's secrets.

- **Different Linear events:** edit `toEmbed()` in `worker.js` (and `LINEAR_RESOURCES` in `setup.sh` for new types), then re-run the script.
- **Different GitHub events:** repo Settings → Webhooks → the Discord hook (`GITHUB_EVENTS` in `setup.sh` applies only when the hook is created).
- **New Discord webhook URL:** update `.env` and re-run (for `#github`, delete the old GitHub hook first).
- **Debugging:** `cd tools/discord && npx wrangler@4.156.0 tail` shows live worker requests; Linear → Settings → API → Webhooks shows delivery failures.
