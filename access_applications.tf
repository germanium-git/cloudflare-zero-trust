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
