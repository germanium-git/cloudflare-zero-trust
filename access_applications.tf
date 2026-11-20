resource "cloudflare_zero_trust_access_application" "motioneye" {
  account_id                 = var.cloudflare_account_id
  name                       = "motioneye"
  domain                     = "motioneye.germanium.cz"
  type                       = "self_hosted"
  session_duration           = "24h"
  app_launcher_visible       = true
  auto_redirect_to_identity  = false
  enable_binding_cookie      = false
  http_only_cookie_attribute = false
  options_preflight_bypass   = false

  destinations = [{
    type = "public"
    uri  = "motioneye.germanium.cz"
  }]

  policies = [
    { id = cloudflare_zero_trust_access_policy.local_network.id, precedence = 1 },
    { id = cloudflare_zero_trust_access_policy.gmx_gmail_emails.id, precedence = 2 },
  ]
}

resource "cloudflare_zero_trust_access_application" "warp_login" {
  account_id                = var.cloudflare_account_id
  name                      = "Warp Login App"
  domain                    = "germaniumtunnel.cloudflareaccess.com/warp"
  type                      = "warp"
  session_duration          = "24h"
  auto_redirect_to_identity = false
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.google.id]

  policies = [
    { id = cloudflare_zero_trust_access_policy.gmx_gmail_emails.id, precedence = 1 },
  ]
}

resource "cloudflare_zero_trust_access_application" "homeassist" {
  account_id                  = var.cloudflare_account_id
  name                        = "homeassist"
  domain                      = "homeassist.germanium.cz"
  type                        = "self_hosted"
  session_duration            = "24h"
  allow_authenticate_via_warp = true
  app_launcher_visible        = true
  auto_redirect_to_identity   = false
  enable_binding_cookie       = false
  http_only_cookie_attribute  = false
  options_preflight_bypass    = false

  destinations = [{
    type = "public"
    uri  = "homeassist.germanium.cz"
  }]

  policies = [
    { id = cloudflare_zero_trust_access_policy.local_network.id, precedence = 1 },
    { id = cloudflare_zero_trust_access_policy.gmx_gmail_emails.id, precedence = 2 },
  ]
}

# Cluster sites exposed through the k8s-ingress tunnel (all HTTPRoutes on traefik-gateway-tls-tunnel,
# argocd repo). Every *.germanium.cz name with a proxied DNS record reaches Traefik through the tunnel,
# so each one needs an Access application here, or it is open to the internet.
locals {
  cluster_sites = {
    wiki      = "wiki.germanium.cz"
    esphome   = "esphome.germanium.cz"
    grafana   = "grafana.germanium.cz"
    n8n       = "n8n.germanium.cz"
    paperless = "paperless.germanium.cz"
  }
}

# paperless had its own resource on branch paperless-gateway-cloudflare (PR #1), which is not on main.
# If that resource is in the state, this keeps the existing Access app instead of replacing it;
# if it isn't, Terraform ignores the block.
moved {
  from = cloudflare_zero_trust_access_application.paperless
  to   = cloudflare_zero_trust_access_application.cluster_site["paperless"]
}

resource "cloudflare_zero_trust_access_application" "cluster_site" {
  for_each = local.cluster_sites

  account_id                  = var.cloudflare_account_id
  name                        = each.key
  domain                      = each.value
  type                        = "self_hosted"
  session_duration            = "24h"
  allow_authenticate_via_warp = true
  app_launcher_visible        = true
  auto_redirect_to_identity   = false
  enable_binding_cookie       = false
  http_only_cookie_attribute  = false
  options_preflight_bypass    = false

  destinations = [{
    type = "public"
    uri  = each.value
  }]

  policies = [
    { id = cloudflare_zero_trust_access_policy.local_network.id, precedence = 1 },
    { id = cloudflare_zero_trust_access_policy.gmx_gmail_emails.id, precedence = 2 },
  ]
}
