packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

// Build a 26.04 LTS VM from the live-server ISO via autoinstall (declarative
// cloud-init user-data), then convert it to a Proxmox template.
source "proxmox-iso" "ubuntu" {
  // --- connection ---
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  insecure_skip_tls_verify = var.insecure_skip_tls_verify
  node                     = var.proxmox_node

  // --- output template ---
  vm_name              = var.template_name
  template_name        = var.template_name
  template_description = "Ubuntu 26.04 LTS template — sudo user, ssh keys, hardened sshd. Built by Packer."
  cores                = var.vm_cores
  memory               = var.vm_memory
  qemu_agent           = true
  scsi_controller      = "virtio-scsi-single"
  os                   = "l26"

  // --- installer ISO ---
  boot_iso {
    type             = "scsi"
    iso_url          = var.iso_url
    iso_checksum     = var.iso_checksum
    iso_storage_pool = var.iso_storage_pool
    iso_download_pve = true
    unmount          = true
  }

  disks {
    type         = "scsi"
    disk_size    = var.disk_size
    storage_pool = var.disk_storage_pool
    format       = "raw"
  }

  network_adapters {
    model  = "virtio"
    bridge = var.network_bridge
  }

  // Keep a cloud-init drive on the template so Terraform/Tofu/`qm clone` can
  // still set per-VM hostname, IP and any extra keys at clone time.
  cloud_init              = true
  cloud_init_storage_pool = var.disk_storage_pool

  // --- autoinstall seed served over HTTP to the installer ---
  http_content = {
    "/meta-data" = ""
    "/user-data" = templatefile("http/user-data.pkrtpl", {
      username      = var.img_username
      password_hash = var.img_password_hash
      hostname      = "ubuntu-template"
    })
  }

  // GRUB menu-edit approach: append the autoinstall kernel args to the first
  // boot entry. Editing (vs the `c` console) keeps the ';' in the datasource
  // arg literal instead of GRUB treating it as a command separator.
  boot_wait = "5s"
  boot_command = [
    "<wait>e<wait>",
    "<down><down><down><end> autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10><wait>"
  ]

  // --- how Packer reaches the installed VM to provision it ---
  ssh_username         = var.img_username
  ssh_private_key_file = var.build_ssh_private_key_file
  ssh_timeout          = "30m"
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  // Build-time prep + deprovision — the imperative, run-once steps that don't fit
  // declarative cloud-init. User/key/ssh/timezone/auto-update config lives in the
  // autoinstall user-data, not here.
  provisioner "shell" {
    execute_command  = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline           = [
      // patch the image so clones don't start months behind
      "apt-get update && apt-get -y dist-upgrade",
      // host firewall: deny inbound except ssh
      "ufw default deny incoming",
      "ufw default allow outgoing",
      "ufw allow 22/tcp",
      "ufw --force enable",
      // slim: remove snapd and keep it from coming back
      "apt-get -y purge snapd || true",
      "apt-mark hold snapd || true",
      "rm -rf /snap /var/snap /var/lib/snapd /root/snap",
      // deprovision so every clone gets a unique identity
      "rm -f /etc/ssh/ssh_host_*",
      "cloud-init clean --logs --seed || true",
      "truncate -s 0 /etc/machine-id",
      "rm -f /var/lib/dbus/machine-id && ln -s /etc/machine-id /var/lib/dbus/machine-id",
      "apt-get -y autoremove --purge && apt-get -y clean",
      "rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*",
      "cat /dev/null > ~/.bash_history || true",
    ]
  }
}
