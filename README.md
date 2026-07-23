# cloudflare-zero-trust

Terraform configuration for this Cloudflare Zero Trust account (Access, Gateway, Tunnels, identity providers, device posture). State is stored remotely in Terraform Cloud (org `mygermanium`, workspace `cloudflare-zero-trust`).

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.14`
- A Terraform Cloud account with access to the `mygermanium` org, and `terraform login` run locally
- A Cloudflare API token with permissions for Zero Trust / Access / Gateway / Tunnels

## Secrets: `.env.cloudflare`

Credentials are **not** stored in this repo. They're kept in a local `.env.cloudflare` file, which is listed in `.gitignore` and will not exist on a fresh checkout — you need to create it yourself.

Create `.env.cloudflare` in the repo root with:

```sh
export CLOUDFLARE_API_TOKEN="<cloudflare api token>"
export CLOUDFLARE_ACCOUNT_ID="<cloudflare account id>"
export TF_VAR_google_idp_client_secret="<google oauth client secret>"
```

Where to get each value:

- `CLOUDFLARE_API_TOKEN` — [Cloudflare dashboard → My Profile → API Tokens](https://dash.cloudflare.com/profile/api-tokens). Create a token scoped to this account's Zero Trust resources.
- `CLOUDFLARE_ACCOUNT_ID` — Cloudflare dashboard → any domain/account home page, right-hand sidebar ("Account ID").
- `TF_VAR_google_idp_client_secret` — [Google Cloud Console → APIs & Services → Credentials](https://console.cloud.google.com/apis/credentials), under the OAuth 2.0 Client ID used for the Google Access identity provider. Cloudflare never returns this value once set, so it must be re-supplied from Google's side if lost.

This file must be **sourced** into your shell before running Terraform — Terraform does not read `.env` files automatically, only real environment variables (`TF_VAR_*`) or `.tfvars` files.

## Running Terraform locally

```sh
source .env.cloudflare

terraform init
terraform plan
terraform apply
```

If `terraform plan` prompts for `var.google_idp_client_secret`, it means `.env.cloudflare` wasn't sourced (or wasn't created yet) in the current shell session.

`cloudflare_account_id` is also required but is non-secret and already set in `terraform.tfvars` (see `terraform.tfvars.example` for the template).
