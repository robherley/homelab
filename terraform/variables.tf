variable "pm_api_url" {
  default = "https://r720-pve.lab.reb.gg:8006/api2/json"
}

variable "pm_user" {
  default = "terraform@pve"
}

variable "pm_password" {
  sensitive = true
}

variable "ssh_key" {
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKrOJrpYRgEiuGuoNhyPbeEldjIRkwRG/fjjySPUks/y robherley13@gmail.com"
}
