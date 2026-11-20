#!/usr/bin/env bash
# Collects the secrets .github/workflows/terraform.yml needs from your local setup and
# (with --apply) stores them as GitHub Actions repo secrets via `gh secret set`.
#
# Sources:
#   TF_API_TOKEN              ~/.terraform.d/credentials.tfrc.json (written by `terraform login`)
#   CLOUDFLARE_API_TOKEN      .env.cloudflare
#   CLOUDFLARE_ACCOUNT_ID     .env.cloudflare, falling back to terraform.tfvars
#   GOOGLE_IDP_CLIENT_SECRET  .env.cloudflare (TF_VAR_google_idp_client_secret)
#   TRUSTED_SOURCE_IPS        terraform.tfvars (trusted_source_ips list -> ["a","b"])
#
# Usage:
#   scripts/sync-github-secrets.sh           # dry run: shows what was found (values masked)
#   scripts/sync-github-secrets.sh --apply   # also uploads the secrets to GitHub
#
# Values are never printed and are sent to gh on stdin, not on the command line.

set -euo pipefail

cd "$(dirname "$0")/.."

APPLY=false
[[ "${1:-}" == "--apply" ]] && APPLY=true

die() { echo "error: $*" >&2; exit 1; }
command -v jq >/dev/null || die "jq is required"
command -v gh >/dev/null || die "gh is required"

# --- .env.cloudflare: source in a subshell so it doesn't leak into this shell's env ----
[[ -f .env.cloudflare ]] || die ".env.cloudflare not found (see README.md)"
env_get() { (set +u; source ./.env.cloudflare >/dev/null 2>&1; printf '%s' "${!1:-}"); }

CLOUDFLARE_API_TOKEN="$(env_get CLOUDFLARE_API_TOKEN)"
CLOUDFLARE_ACCOUNT_ID="$(env_get CLOUDFLARE_ACCOUNT_ID)"
GOOGLE_IDP_CLIENT_SECRET="$(env_get TF_VAR_google_idp_client_secret)"

# --- terraform.tfvars --------------------------------------------------------------------
TRUSTED_SOURCE_IPS=""
if [[ -f terraform.tfvars ]]; then
  if [[ -z "$CLOUDFLARE_ACCOUNT_ID" ]]; then
    CLOUDFLARE_ACCOUNT_ID="$(sed -nE 's/^[[:space:]]*cloudflare_account_id[[:space:]]*=[[:space:]]*"([^"]*)".*/\1/p' terraform.tfvars)"
  fi
  # Grab the trusted_source_ips = [ ... ] block, drop comments, keep quoted entries,
  # and turn them into a JSON array (which is also a valid HCL list literal).
  TRUSTED_SOURCE_IPS="$(
    awk '/^[[:space:]]*trusted_source_ips[[:space:]]*=/{f=1} f{print} f&&/\]/{exit}' terraform.tfvars \
      | sed -E 's/#.*//' \
      | grep -oE '"[^"]+"' \
      | jq -sc . || true
  )"
fi

# --- Terraform Cloud token from `terraform login` ------------------------------------------
TF_CREDS="${TF_CLI_CONFIG_DIR:-$HOME/.terraform.d}/credentials.tfrc.json"
TF_API_TOKEN=""
[[ -f "$TF_CREDS" ]] && TF_API_TOKEN="$(jq -r '.credentials["app.terraform.io"].token // empty' "$TF_CREDS")"

# --- Report & upload --------------------------------------------------------------------------
declare -A SOURCES=(
  [TF_API_TOKEN]="$TF_CREDS"
  [CLOUDFLARE_API_TOKEN]=".env.cloudflare"
  [CLOUDFLARE_ACCOUNT_ID]=".env.cloudflare / terraform.tfvars"
  [GOOGLE_IDP_CLIENT_SECRET]=".env.cloudflare"
  [TRUSTED_SOURCE_IPS]="terraform.tfvars"
)
NAMES=(TF_API_TOKEN CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID GOOGLE_IDP_CLIENT_SECRET TRUSTED_SOURCE_IPS)

missing=0
for name in "${NAMES[@]}"; do
  val="${!name}"
  if [[ -z "$val" ]]; then
    printf '  %-26s MISSING   (expected in %s)\n' "$name" "${SOURCES[$name]}"
    missing=1
  elif [[ "$name" == "TRUSTED_SOURCE_IPS" ]]; then
    printf '  %-26s found     %s entr%s\n' "$name" "$(jq length <<<"$val")" "$( [[ $(jq length <<<"$val") == 1 ]] && echo y || echo ies)"
  else
    printf '  %-26s found     %d chars, ends …%s\n' "$name" "${#val}" "${val: -4}"
  fi
done

if ! $APPLY; then
  echo
  echo "Dry run. Re-run with --apply to store these as secrets in $(gh repo view --json nameWithOwner -q .nameWithOwner)."
  exit $missing
fi

(( missing == 0 )) || die "some values are missing; fix them before --apply"

for name in "${NAMES[@]}"; do
  printf '%s' "${!name}" | gh secret set "$name" --app actions
done
echo
gh secret list --app actions
