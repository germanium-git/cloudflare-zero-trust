# Reusable Access policies, referenced by id from access_applications.tf.
resource "cloudflare_zero_trust_access_policy" "local_network" {
  account_id       = var.cloudflare_account_id
  decision         = "allow"
  name             = "local_network"
  session_duration = "24h"
  include = [{
    ip = {
      ip = "172.31.1.0/24"
    }
  }]
}

resource "cloudflare_zero_trust_access_policy" "gmx_gmail_emails" {
  account_id       = var.cloudflare_account_id
  decision         = "allow"
  name             = "emails gmx & gmail"
  session_duration = "24h"
  connection_rules = {
    rdp = {
      allowed_clipboard_local_to_remote_formats = ["text"]
      allowed_clipboard_remote_to_local_formats = ["text"]
    }
  }
  include = [
    { email = { email = "petr.nemec@gmx.com" } },
    { email = { email = "pnemec.posta@gmail.com" } },
    { email = { email = "voj.nmc@gmail.com" } },
  ]
}
