variable "proxmox_node" {
  type    = string
  default = "r7920"
}

variable "datastore" {
  type    = string
  default = "local" # downloaded image (import), snippet, cloud-init drive, and VM disk
}

variable "template_vmid" {
  type    = number
  default = 9000
}

variable "disk_size" {
  type    = number
  default = 16 # GB
}

# Private key for root@<node> — the snippet upload uses SSH, and the provider
# ignores ~/.ssh/config. Must be passphrase-less (or loaded in ssh-agent instead).
variable "proxmox_ssh_private_key_file" {
  type    = string
  default = "~/.ssh/id_ed25519"
}

# Image user — from 1Password via TF_VAR_* (op run). Never commit these.
variable "img_username" {
  type = string
}

variable "img_password_hash" {
  type      = string
  sensitive = true
}
