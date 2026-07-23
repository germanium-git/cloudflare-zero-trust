terraform {
  required_version = ">= 1.14"

  cloud {
    organization = "mygermanium"

    workspaces {
      name = "cloudflare-zero-trust"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.21"
    }
  }
}
