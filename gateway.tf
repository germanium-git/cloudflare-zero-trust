# Cloudflare-managed mTLS root certificate used for Gateway TLS decryption.
resource "cloudflare_zero_trust_gateway_certificate" "root" {
  account_id = var.cloudflare_account_id
}

resource "cloudflare_zero_trust_gateway_logging" "this" {
  account_id = var.cloudflare_account_id
  redact_pii = false
  settings_by_rule_type = {
    dns = {
      log_all    = true
      log_blocks = false
    }
    http = {
      log_all    = true
      log_blocks = false
    }
    l4 = {
      log_all    = true
      log_blocks = false
    }
  }
}

resource "cloudflare_zero_trust_gateway_settings" "this" {
  account_id = var.cloudflare_account_id
  settings = {
    certificate = {
      id = cloudflare_zero_trust_gateway_certificate.root.id
    }
    tls_decrypt = {
      enabled = false
    }
  }
}
