# Ubuntu 26.04 LXC template. Proxmox doesn't run cloud-init for containers, so
# instead of first-boot config the template is baked: create a container from
# the stock template, run lxc/provision.sh inside it, then convert to a template.

# 1. Stock Proxmox Ubuntu 26.04 container template (checksum from aplinfo-pve-9.dat).
resource "proxmox_download_file" "ubuntu_2604_lxc" {
  content_type       = "vztmpl"
  datastore_id       = var.datastore
  node_name          = var.proxmox_node
  url                = "http://download.proxmox.com/images/system/ubuntu-26.04-standard_26.04-1_amd64.tar.zst"
  checksum           = "d5607f124d01f8ddfebd8e7da34c0022fb2a464e1662ee1e39a13f5ed1bae08a7364c486247fbd9f69f26c710729884ee5047aadb89f33a40066cd5f0d9def88"
  checksum_algorithm = "sha512"
}

locals {
  lxc_provision = templatefile("${path.module}/lxc/provision.sh.tftpl", {
    img_username = var.img_username
  })
  lxc_ssh = "ssh -o BatchMode=yes -i ${pathexpand(var.proxmox_ssh_private_key_file)} root@${var.proxmox_ssh_host}"
}

# Changes whenever the provisioning inputs do, forcing a rebuild of the template.
resource "terraform_data" "lxc_inputs" {
  input = sha256("${local.lxc_provision}${var.img_password_hash}")
}

# 2. Build container. Starts running so it can be provisioned; step 3 stops it
#    and converts it to a template out-of-band (hence ignore_changes).
resource "proxmox_virtual_environment_container" "ubuntu_2604" {
  node_name     = var.proxmox_node
  vm_id         = var.lxc_template_vmid
  unprivileged  = true
  started       = true
  start_on_boot = true # clones auto-start when the Proxmox host boots

  features {
    nesting = true # modern systemd needs it in unprivileged CTs (PVE default)
  }
  cpu { cores = 2 }
  memory {
    dedicated = 4096
    swap      = 512
  }

  disk {
    datastore_id = var.datastore
    size         = var.disk_size
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  operating_system {
    template_file_id = proxmox_download_file.ubuntu_2604_lxc.id
    type             = "ubuntu"
  }

  initialization {
    hostname = "ubuntu-2604-lxc"
    ip_config {
      ipv4 { address = "dhcp" }
    }
  }

  lifecycle {
    ignore_changes       = [started, template]
    replace_triggered_by = [terraform_data.lxc_inputs]
  }
}

# 3. Provision over root SSH to the node (`pct exec`), set the password, then
#    stop + template. Re-runs whenever the container is replaced.
resource "terraform_data" "lxc_bake" {
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.ubuntu_2604.id]
  }

  provisioner "local-exec" {
    command     = "printf '%s' \"$SCRIPT\" | ${local.lxc_ssh} 'pct exec ${var.lxc_template_vmid} -- bash -s'"
    environment = { SCRIPT = local.lxc_provision }
  }

  provisioner "local-exec" {
    command = "printf '%s:%s\\n' \"$IMG_USER\" \"$IMG_HASH\" | ${local.lxc_ssh} 'pct exec ${var.lxc_template_vmid} -- chpasswd -e'"
    environment = {
      IMG_USER = var.img_username
      IMG_HASH = var.img_password_hash
    }
  }

  provisioner "local-exec" {
    command = "${local.lxc_ssh} 'pct stop ${var.lxc_template_vmid} && pct template ${var.lxc_template_vmid}'"
  }
}
