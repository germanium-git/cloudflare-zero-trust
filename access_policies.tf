# Reusable Access policies, referenced by id from access_applications.tf.
#
# Despite the resource name, this matches var.trusted_source_ips (public IPs/CIDRs,
# e.g. home WAN IP, VPN egress IPs) rather than an RFC1918 LAN range: Cloudflare Access
# only ever sees a request's public source IP at its edge, so a private CIDR here would
# never actually match browser traffic, even from that LAN.
#
# decision = "bypass" (not "allow") is required to actually skip the login screen for
# matching IPs - "allow" still presents the login page on initial access even when the
# IP condition is satisfied; only "bypass" disables Access enforcement for the match.
# Keep this scoped to a narrow, explicit IP list since bypass skips all security checks.
resource "cloudflare_zero_trust_access_policy" "local_network" {
  account_id = var.cloudflare_account_id
  decision   = "bypass"
  name       = "trusted static IPs"
  include = [
    for ip in var.trusted_source_ips : { ip = { ip = ip } }
  ]
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
