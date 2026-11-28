#!/usr/bin/env bash
# Connect GitHub and Linear to Discord. Idempotent: re-running only adds what is missing.
#   GitHub -> #github : native Discord GitHub webhook (<discord webhook>/github)
#   Linear -> #linear : Linear webhook -> Cloudflare Worker (worker.js) -> Discord
# Needs in <repo>/.env: LINEAR_API_KEY, DISCORD_GITHUB_WEBHOOK, DISCORD_LINEAR_WEBHOOK.
# Needs: curl, jq, gh (logged in, repo admin), npx + `npx wrangler@4.156.0 login` done once.
set -euo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$DIR/../lib.sh"
: "${DISCORD_GITHUB_WEBHOOK:?missing in $ROOT/.env}" "${DISCORD_LINEAR_WEBHOOK:?missing in $ROOT/.env}"

REPO="Zer0Hiro/CrysisSync"
TEAM_KEY="CS"
GITHUB_EVENTS='["push","pull_request","pull_request_review","pull_request_review_comment"]'
LINEAR_RESOURCES='["Issue","Comment"]'
wrangler() { (cd "$DIR" && npx --yes wrangler@4.156.0 "$@"); }

# 1. GitHub -> Discord (#github)
gh_url="$DISCORD_GITHUB_WEBHOOK/github"
hook_id=$(gh api "repos/$REPO/hooks" | jq -r --arg u "$gh_url" 'map(select(.config.url == $u)) | .[0].id // empty')
if [[ -n "$hook_id" ]]; then
  echo "GitHub webhook already exists (id $hook_id)"
else
  hook_id=$(jq -n --arg u "$gh_url" --argjson e "$GITHUB_EVENTS" \
      '{name: "web", active: true, events: $e, config: {url: $u, content_type: "json"}}' |
    gh api "repos/$REPO/hooks" --input - --jq '.id')
  echo "Created GitHub webhook (id $hook_id)"
fi

# 2. Signing secret shared by the Linear webhook and the worker (kept in .env)
if [[ -z "${LINEAR_WEBHOOK_SECRET:-}" ]]; then
  LINEAR_WEBHOOK_SECRET=$(openssl rand -hex 32)
  [[ -z $(tail -c1 "$ROOT/.env") ]] || echo >> "$ROOT/.env"   # .env may lack a final newline
  printf 'LINEAR_WEBHOOK_SECRET=%s\n' "$LINEAR_WEBHOOK_SECRET" >> "$ROOT/.env"
  echo "Generated LINEAR_WEBHOOK_SECRET (saved in .env)"
fi

# 3. Deploy the worker and give it its secrets (values via stdin, never on the command line)
deploy_out=$(wrangler deploy 2>&1) || { echo "$deploy_out" >&2; exit 1; }
worker_url=$(grep -oE 'https://[a-z0-9.-]+\.workers\.dev' <<<"$deploy_out" | head -1)
[[ -n "$worker_url" ]] || { echo "$deploy_out" >&2; echo "Could not find the worker URL in the deploy output" >&2; exit 1; }
printf %s "$DISCORD_LINEAR_WEBHOOK" | wrangler secret put DISCORD_WEBHOOK_URL >/dev/null
printf %s "$LINEAR_WEBHOOK_SECRET" | wrangler secret put LINEAR_WEBHOOK_SECRET >/dev/null
echo "Worker deployed: $worker_url"

# 4. Linear -> worker (create, or re-sync the secret if the webhook already exists)
data=$(gql '{ teams { nodes { id key } } webhooks { nodes { id url } } }')
team_id=$(jq -r --arg k "$TEAM_KEY" '.teams.nodes[] | select(.key == $k) | .id' <<<"$data")
[[ -n "$team_id" ]] || { echo "No Linear team with key $TEAM_KEY - run tools/linear/setup.sh first" >&2; exit 1; }
webhook_id=$(jq -r --arg u "$worker_url" '.webhooks.nodes[] | select(.url == $u) | .id' <<<"$data")
if [[ -n "$webhook_id" ]]; then
  gql 'mutation($id: String!, $input: WebhookUpdateInput!) { webhookUpdate(id: $id, input: $input) { success } }' \
    "$(jq -n --arg id "$webhook_id" --arg s "$LINEAR_WEBHOOK_SECRET" --argjson r "$LINEAR_RESOURCES" \
      '{id: $id, input: {secret: $s, resourceTypes: $r, enabled: true}}')" >/dev/null
  echo "Linear webhook already exists (secret and events re-synced)"
else
  gql 'mutation($input: WebhookCreateInput!) { webhookCreate(input: $input) { success } }' \
    "$(jq -n --arg u "$worker_url" --arg t "$team_id" --arg s "$LINEAR_WEBHOOK_SECRET" --argjson r "$LINEAR_RESOURCES" \
      '{input: {label: "Discord #linear", url: $u, teamId: $t, secret: $s, resourceTypes: $r, enabled: true}}')" >/dev/null
  echo "Created Linear webhook -> $worker_url"
fi
echo "Done. GitHub events go to #github, Linear issue/comment events go to #linear."
