resource "cloudflare_zero_trust_access_identity_provider" "one_time_pin" {
  account_id = var.cloudflare_account_id
  name       = ""
  type       = "onetimepin"
  config     = {}
}

resource "cloudflare_zero_trust_access_identity_provider" "google" {
  account_id = var.cloudflare_account_id
  name       = "Google"
  type       = "google"
  config = {
    client_id     = "293242150923-dhufn156rvnq85mb6o92p9ej7fdcn9c8.apps.googleusercontent.com"
    client_secret = var.google_idp_client_secret
  }
  scim_config = {
    enabled                  = false
    group_member_deprovision = false
    identity_update_behavior = "no_action"
    seat_deprovision         = false
    user_deprovision         = false
  }
}
