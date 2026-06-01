// ---------------------------------------------------------------------------
// Proxmox connection
// ---------------------------------------------------------------------------

variable "proxmox_url" {
  type    = string
  default = "https://r7920.lab.reb.gg:8006/api2/json"
}

variable "proxmox_node" {
  type    = string
  default = "r7920"
}

variable "proxmox_username" {
  type    = string
  default = "scripts@pve!scripts"
}

variable "proxmox_token" {
  type      = string
  sensitive = true
}

// The Proxmox host uses a self-signed/internal cert (same reason the ansible
// inventory sets validate_certs: false), so skip verification by default.
variable "insecure_skip_tls_verify" {
  type    = bool
  default = true
}

// ---------------------------------------------------------------------------
// Storage / network (match your Proxmox setup)
// ---------------------------------------------------------------------------

variable "iso_storage_pool" {
  type    = string
  default = "local"
}

variable "disk_storage_pool" {
  type    = string
  default = "local"
}

variable "network_bridge" {
  type    = string
  default = "vmbr0"
}

// ---------------------------------------------------------------------------
// Ubuntu 26.04 LTS live-server ISO
// Bump url + checksum together from https://releases.ubuntu.com/<ver>/SHA256SUMS
// when moving to a new point release or LTS.
// ---------------------------------------------------------------------------

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/26.04/ubuntu-26.04-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:dec49008a71f6098d0bcfc822021f4d042d5f2db279e4d75bdd981304f1ca5d9"
}

// ---------------------------------------------------------------------------
// Build-time SSH access
// Packer logs into the build VM as the image user to run the deprovision step.
// Access comes from the GitHub keys imported by cloud-init (ssh_import_id), which
// already include the key below — so Packer connects with your existing key.
// ---------------------------------------------------------------------------

variable "build_ssh_private_key_file" {
  type        = string
  description = "Matching private key Packer connects with."
  default     = "~/.ssh/id_ed25519"
}

// ---------------------------------------------------------------------------
// Image user identity — supplied at build time from the 1Password "Image-User"
// item so neither the username nor the hash lands in git. See README.
//   PKR_VAR_img_username       op://Homelab/Image-User/username
//   PKR_VAR_img_password_hash  op://Homelab/Image-User/password_hash
// ---------------------------------------------------------------------------

variable "img_username" {
  type        = string
  description = "Login/sudo account baked into the image."
}

// sha512crypt hash for the image user's console / fallback password. Password
// SSH auth is disabled, so this is console-only; key auth is the normal path.
variable "img_password_hash" {
  type      = string
  sensitive = true
}

// ---------------------------------------------------------------------------
// Output template
// ---------------------------------------------------------------------------

variable "template_name" {
  type    = string
  default = "ubuntu-2604"
}

variable "vm_cores" {
  type    = number
  default = 2
}

variable "vm_memory" {
  type    = number
  default = 4096
}

variable "disk_size" {
  type    = string
  default = "16G"
}
