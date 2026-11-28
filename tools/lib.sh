# Shared helpers for tools/*/setup.sh. Source it; it loads <repo>/.env and defines gql().
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
if [[ -f "$ROOT/.env" ]]; then set -a; source "$ROOT/.env"; set +a; fi

gql() { # gql QUERY [VARIABLES_JSON] -> prints .data of a Linear GraphQL call, exits on API errors
  : "${LINEAR_API_KEY:?LINEAR_API_KEY is empty - put your personal API key in $ROOT/.env (see tools/linear/README.md)}"
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
