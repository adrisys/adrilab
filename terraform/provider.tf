# ==============================================================================
# TERRAFORM CONFIGURATION
# ==============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }

  # Remote State Backend Configuration
  # Note: bucket and region are set via environment variables:
  # TF_VAR_bucket and TF_VAR_region in GitHub Actions
  backend "s3" {
    encrypt                     = true
    key                         = "terraform/terraform.tfstate"
    skip_credentials_validation = false
    skip_region_validation      = false
  }
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