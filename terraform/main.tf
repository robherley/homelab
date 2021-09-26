terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.8.0"
    }
  }
}

resource "proxmox_vm_qemu" "testing" {
  name        = "testing"
  target_node = "r720-pve"

  clone   = "ubuntu-focal-cloudinit"
  os_type = "cloud-init"

  cores    = 4
  sockets  = "1"
  memory   = 4096
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    size    = "24G"
    type    = "scsi"
    storage = "local-lvm"
  }

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = true
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.1.201/24,gw=192.168.1.1"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
