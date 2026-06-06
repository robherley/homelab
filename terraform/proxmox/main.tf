# 1. Download the official Ubuntu 26.04 cloud image onto Proxmox. content_type
#    "import" (not "iso") so PVE 9 will let it be imported as a VM disk; needs the
#    `import` content type enabled on the datastore.
resource "proxmox_download_file" "ubuntu_2604" {
  content_type       = "import"
  datastore_id       = var.datastore
  node_name          = var.proxmox_node
  url                = "https://cloud-images.ubuntu.com/releases/26.04/release/ubuntu-26.04-server-cloudimg-amd64.img"
  file_name          = "ubuntu-26.04-cloudimg.qcow2" # import content rejects .img; the image is qcow2
  checksum           = "dced94c031cc1f23dee14419a3723a5b110df9938de0ac31913a2bfd07c755b4"
  checksum_algorithm = "sha256"
}

# 2. Upload the cloud-init snippet (rendered with the image-user creds from
#    1Password). Delivered as VENDOR-data so Proxmox still generates the user-data
#    (which carries the per-clone hostname).
resource "proxmox_virtual_environment_file" "vendor_data" {
  content_type = "snippets"
  datastore_id = var.datastore
  node_name    = var.proxmox_node

  source_raw {
    file_name = "ubuntu-2604-vendor.yaml"
    data = templatefile("${path.module}/cloud-init/vendor-data.yaml.tftpl", {
      img_username      = var.img_username
      img_password_hash = var.img_password_hash
    })
  }
}

# 3. The template itself: import the cloud image as the disk, attach a cloud-init
#    drive (per-clone hostname/IP/keys) + the snippet, and mark it a template.
resource "proxmox_virtual_environment_vm" "ubuntu_2604" {
  name      = "ubuntu-2604"
  node_name = var.proxmox_node
  vm_id     = var.template_vmid
  template  = true
  started   = false
  on_boot   = true # clones auto-start when the Proxmox host boots (intentional)

  agent { enabled = true }
  cpu {
    type  = "host"
    cores = 4
  }
  memory { dedicated = 8192 }
  operating_system { type = "l26" }
  scsi_hardware  = "virtio-scsi-single"
  serial_device {}

  network_device { bridge = "vmbr0" }

  disk {
    datastore_id = var.datastore
    import_from  = proxmox_download_file.ubuntu_2604.id
    interface    = "scsi0"
    size         = var.disk_size
  }

  initialization {
    datastore_id        = var.datastore
    interface           = "ide2"
    vendor_data_file_id = proxmox_virtual_environment_file.vendor_data.id
    ip_config {
      ipv4 { address = "dhcp" }
    }
  }
}
