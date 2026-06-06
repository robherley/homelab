terraform {
  required_version = ">= 1.7"

  cloud {
    organization = "reb-labs"
    workspaces {
      name = "proxmox"
    }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }
}
