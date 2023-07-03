terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">=1.0.0"
    }
  }
  required_version = ">= 0.14"
}
provider "proxmox" {
  pm_api_url = "https://PROXMOX-URL:8006/api2/json"
  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = "tfuser@pve!terraform"
  # this is the full secret wrapped in quotes.
  pm_api_token_secret = var.proxmox_api_secret_token
  pm_tls_insecure     = true

  #debug log
  #   pm_log_enable = true
  #   pm_log_file   = "./terraform-plugin-proxmox.log"
  #   pm_debug      = true
  #   pm_log_levels = {
  #     _default    = "debug"
  #     _capturelog = ""
  #   }
}
