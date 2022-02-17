variable "pm_api_url" {
  default = "https://10.0.0.100:8006/api2/json"
}

variable "pm_user" {
  default = "terraform@pve"
}

variable "pm_password" {
  sensitive = true
}

variable "vm_template_name" {
  default = "ubuntu-cloudinit-template"
}

variable "lxc_template_name" {
  default = "ubuntu-ct-template"
}