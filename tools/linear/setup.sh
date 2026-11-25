#!/usr/bin/env bash
# Configure the CrysisSync Linear workspace: team CS, weekly cycles, "In Review" state, Area labels.
# Idempotent: re-running only changes what is missing. Needs curl + jq and LINEAR_API_KEY in <repo>/.env.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
if [[ -f "$ROOT/.env" ]]; then set -a; source "$ROOT/.env"; set +a; fi
: "${LINEAR_API_KEY:?LINEAR_API_KEY is empty - put your personal API key in $ROOT/.env (see tools/linear/README.md)}"

TEAM_NAME="CrysisSync"
TEAM_KEY="CS"
CYCLE_WEEKS=2
CYCLE_START_DAY=0          # 0 = Sunday
AUTO_ARCHIVE_MONTHS=1
REVIEW_STATE="In Review"
LABEL_GROUP="Area"
AREA_LABELS=(use-case requirements diagram spec tests docs)

gql() { # gql QUERY [VARIABLES_JSON] -> prints .data, exits on API errors
  local resp vars=${2:-}
  [[ -n "$vars" ]] || vars='{}'
  resp=$(jq -n --arg q "$1" --argjson v "$vars" '{query: $q, variables: $v}' |
    curl -sS https://api.linear.app/graphql \
      -H "Content-Type: application/json" -H "Authorization: $LINEAR_API_KEY" --data @-)
  if jq -e '.errors' <<<"$resp" >/dev/null; then
    echo "Linear API error:" >&2; jq '.errors' <<<"$resp" >&2; exit 1
  fi
  jq '.data' <<<"$resp"
}

TEAM_FIELDS='id name key cyclesEnabled cycleDuration cycleStartDay autoArchivePeriod
  states { nodes { id name type position } }
  labels(first: 100) { nodes { id name isGroup parent { id } } }'

load_team() { TEAM=$(gql "query(\$id: String!) { team(id: \$id) { $TEAM_FIELDS } }" "$(jq -n --arg id "$TEAM_ID" '{id: $id}')" | jq '.team'); }

# 1. Find the team: one already keyed CS, otherwise the single default team created at signup.
teams=$(gql "{ viewer { name } organization { name } teams { nodes { id key name } } }")
echo "Signed in as $(jq -r '.viewer.name' <<<"$teams") in workspace $(jq -r '.organization.name' <<<"$teams")"
TEAM_ID=$(jq -r --arg k "$TEAM_KEY" '.teams.nodes[] | select(.key == $k) | .id' <<<"$teams")
if [[ -z "$TEAM_ID" ]]; then
  if [[ $(jq '.teams.nodes | length' <<<"$teams") -ne 1 ]]; then
    echo "No team with key $TEAM_KEY and not exactly one team to adopt:" >&2
    jq -r '.teams.nodes[] | "  \(.key)  \(.name)"' <<<"$teams" >&2; exit 1
  fi
  TEAM_ID=$(jq -r '.teams.nodes[0].id' <<<"$teams")
fi
load_team

# 2. Team name, key, cycles, auto-archive.
want=$(jq -n --arg name "$TEAM_NAME" --arg key "$TEAM_KEY" \
  --argjson weeks $CYCLE_WEEKS --argjson day $CYCLE_START_DAY --argjson archive $AUTO_ARCHIVE_MONTHS \
  '{name: $name, key: $key, cyclesEnabled: true, cycleDuration: $weeks, cycleStartDay: $day, autoArchivePeriod: $archive}')
diff=$(jq -n --argjson t "$TEAM" --argjson w "$want" '$w | with_entries(select(.value != $t[.key]))')
if [[ "$diff" != "{}" ]]; then
  echo "Updating team: $(jq -c . <<<"$diff")"
  gql 'mutation($id: String!, $input: TeamUpdateInput!) { teamUpdate(id: $id, input: $input) { success } }' \
    "$(jq -n --arg id "$TEAM_ID" --argjson input "$diff" '{id: $id, input: $input}')" >/dev/null
else
  echo "Team settings already correct"
fi

# 3. "In Review" workflow state between In Progress and Done.
if jq -e --arg n "$REVIEW_STATE" '.states.nodes[] | select(.name == $n)' <<<"$TEAM" >/dev/null; then
  echo "State '$REVIEW_STATE' already exists"
else
  pos=$(jq '(.states.nodes | map(select(.type == "started")) | max_by(.position).position) as $a
          | (.states.nodes | map(select(.type == "completed")) | min_by(.position).position) as $b
          | if $a != null and $b != null then ($a + $b) / 2 else ($a // 0) + 1 end' <<<"$TEAM")
  echo "Creating state '$REVIEW_STATE'"
  gql 'mutation($input: WorkflowStateCreateInput!) { workflowStateCreate(input: $input) { success } }' \
    "$(jq -n --arg t "$TEAM_ID" --arg n "$REVIEW_STATE" --argjson p "$pos" \
      '{input: {teamId: $t, name: $n, type: "started", color: "#f2c94c", position: $p}}')" >/dev/null
fi

# 4. Area label group (one label per issue) and its children.
group_id=$(jq -r --arg n "$LABEL_GROUP" '.labels.nodes[] | select(.name == $n and .isGroup) | .id' <<<"$TEAM")
if [[ -z "$group_id" ]]; then
  echo "Creating label group '$LABEL_GROUP'"
  group_id=$(gql 'mutation($input: IssueLabelCreateInput!) { issueLabelCreate(input: $input) { issueLabel { id } } }' \
    "$(jq -n --arg t "$TEAM_ID" --arg n "$LABEL_GROUP" '{input: {teamId: $t, name: $n, isGroup: true, color: "#5e6ad2"}}')" |
    jq -r '.issueLabelCreate.issueLabel.id')
fi
for label in "${AREA_LABELS[@]}"; do
  if jq -e --arg n "$label" --arg g "$group_id" '.labels.nodes[] | select(.name == $n and .parent.id == $g)' <<<"$TEAM" >/dev/null; then
    continue
  fi
  echo "Creating label '$LABEL_GROUP/$label'"
  gql 'mutation($input: IssueLabelCreateInput!) { issueLabelCreate(input: $input) { success } }' \
    "$(jq -n --arg t "$TEAM_ID" --arg n "$label" --arg g "$group_id" '{input: {teamId: $t, name: $n, parentId: $g}}')" >/dev/null
done

# Summary
load_team
jq -r '"\nTeam: \(.name) (\(.key)) | cycles: \(.cyclesEnabled), \(.cycleDuration)w, start day \(.cycleStartDay) | auto-archive: \(.autoArchivePeriod) mo",
  "States: " + (.states.nodes | sort_by(.position) | map(.name) | join(" -> ")),
  "Labels: " + (.labels.nodes | map(select(.isGroup | not)) | map(.name) | sort | join(", "))' <<<"$TEAM"
