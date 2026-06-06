# Terraform — Proxmox golden templates

Declaratively precreates Proxmox VM templates with the [`bpg/proxmox`] provider.
For Ubuntu 26.04 it downloads the official cloud image, uploads a cloud-init
snippet (rendered from 1Password), and creates the `ubuntu-2604` template — no
installer, no Packer.

State lives in **Terraform Cloud**; plans/applies run **locally** (HCP's hosted
runners can't reach the homelab Proxmox).

## Files

```
versions.tf                       # TFC backend + bpg provider
providers.tf                      # API via env, SSH (private key) for snippet upload
variables.tf                      # node, datastore, vmid, image-user creds
main.tf                           # download image → upload snippet → template
cloud-init/vendor-data.yaml.tftpl # cicustom vendor-data (so Proxmox keeps per-clone hostname)
```

## One-time setup

1. Create the TFC workspace, set its **Execution Mode to Local**, and put your org
   name in `versions.tf` (`organization = ...`).
2. `terraform login` (TFC token).
3. Provider SSH: the snippet upload + disk import use root SSH to the node. The
   provider reads `~/.ssh/id_ed25519` directly (it ignores `~/.ssh/config`); the
   key must be passphrase-less. Override with `TF_VAR_proxmox_ssh_private_key_file`.
4. 1Password: `op` signed in, with the `Image-User` item (`username` +
   `password_hash`) and the Proxmox API token at `Homelab/Proxmox-Scripts`.
5. **Enable the `import` content type on the datastore** (PVE 9 only imports VM
   disks from `import`/`images` content, not `iso`):

   ```sh
   ssh root@r7920 'pvesm set local --content rootdir,iso,images,vztmpl,import,backup,snippets'
   ```

## Use

```sh
just tf proxmox init
just tf proxmox plan
just tf proxmox apply
```

`just tf proxmox` injects the API token + image-user creds from 1Password via
`op read`, then runs `terraform -chdir=terraform/proxmox`. State is in the
Terraform Cloud `reb-labs/proxmox` workspace (Local execution).

## Clone the template

`qm clone 9000 <newid> --name myvm`, then set per-VM cloud-init (hostname/IP/keys).
The snippet config (user, keys, hardening, ufw, snapd removal, upgrade) applies on
first boot.

## Notes

- **Secrets in state:** the rendered snippet (with the password hash) is in TFC
  state — keep the workspace private; consider TFC's state encryption.
- Config applies at **first boot** (cloud-init), not baked into the disk. True disk
  baking would need `virt-customize`; this matches the lightweight model.
- New release / point release: bump the `url` + `checksum` in `main.tf`, re-apply.

[`bpg/proxmox`]: https://registry.terraform.io/providers/bpg/proxmox/latest/docs
