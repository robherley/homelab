resource "proxmox_vm_qemu" "proxy" {
  name        = "proxy"
  target_node = "r720"
  clone       = var.vm_template_name

  cores       = 2
  memory      = 4096
  agent       = 1
}

# todo: migrate to k8s
resource "proxmox_vm_qemu" "analytics" {
  name        = "analytics"
  target_node = "r720"
  clone       = var.vm_template_name

  cores       = 2
  memory      = 2048
  agent       = 1
}