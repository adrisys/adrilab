# ==============================================================================
# TERRAFORM CONFIGURATION FOR LOCAL/HOMELAB USE
# ==============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }

  # Local state storage for homelab use
  # Comment out the S3 backend when running locally
  # backend "s3" {
  #   encrypt                     = true
  #   key                         = "terraform/terraform.tfstate"
  #   skip_credentials_validation = false
  #   skip_region_validation      = false
  # }
}

# ==============================================================================
# PROVIDER CONFIGURATION
# ==============================================================================

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = false
}
