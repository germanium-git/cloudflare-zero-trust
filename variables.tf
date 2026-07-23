variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the Zero Trust resources"
  type        = string
}

variable "google_idp_client_secret" {
  description = "OAuth client secret for the Google Access identity provider. Cloudflare's API never returns this value, so it must be supplied out-of-band (e.g. from the Google Cloud Console credentials page) and is not tracked in state history beyond this run."
  type        = string
  sensitive   = true
}

variable "trusted_source_ips" {
  description = "Public IPs/CIDRs (e.g. home WAN IP, VPN egress IPs) allowed to skip Google login on the local_network Access policy. Cloudflare Access only ever sees a request's public source IP, so private/RFC1918 ranges never match here."
  type        = list(string)
  default     = []
}
