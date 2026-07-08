variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the Zero Trust resources"
  type        = string
}

variable "google_idp_client_secret" {
  description = "OAuth client secret for the Google Access identity provider. Cloudflare's API never returns this value, so it must be supplied out-of-band (e.g. from the Google Cloud Console credentials page) and is not tracked in state history beyond this run."
  type        = string
  sensitive   = true
}
