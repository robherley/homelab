# Non-secret config lives here; only the API token (a secret) comes from env,
# set by the `just tf` recipe via `op read`:
#   PROXMOX_VE_API_TOKEN   scripts@pve!scripts=<secret>
#
# The snippet upload (proxmox_virtual_environment_file) uses SSH — the Proxmox
# API can't write snippets — so the provider also needs root SSH to the node.
# Uses your ssh-agent; the node block maps the node name to its reachable host.
provider "proxmox" {
  endpoint = "https://r7920.lab.reb.gg:8006/"
  insecure = true

  ssh {
    username    = "root"
    private_key = file(pathexpand(var.proxmox_ssh_private_key_file))

    node {
      name    = var.proxmox_node
      address = "r7920.lab.reb.gg"
    }
  }
}
