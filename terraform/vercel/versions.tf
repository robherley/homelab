terraform {
  required_version = ">= 1.7"

  cloud {
    organization = "reb-labs"
    workspaces {
      name = "vercel"
    }
  }

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 3.0"
    }
  }
}
