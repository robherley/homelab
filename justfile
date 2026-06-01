export ANSIBLE_FORCE_COLOR := "1"
export ANSIBLE_CONFIG := justfile_directory() / "ansible/ansible.cfg"
export PROXMOX_TOKEN_SECRET := "op://Homelab/Proxmox-Scripts/token_secret"

# Configure development environment
bootstrap:
    brew bundle

# Run an ansible playbook by name, e.g. `just ansible harden-ssh -- --limit foo`
ansible name *args:
    op run -- ansible-playbook ansible/playbooks/{{name}}.yml {{args}}

# Build the Ubuntu golden image template in Proxmox (secrets via 1Password)
image:
    #!/usr/bin/env bash
    set -euo pipefail
    export PKR_VAR_proxmox_token='op://Homelab/Proxmox-Scripts/token_secret'
    export PKR_VAR_img_username='op://Homelab/Image-User/username'
    export PKR_VAR_img_password_hash='op://Homelab/Image-User/password_hash'
    packer init packer/ubuntu-2604/
    op run -- packer build packer/ubuntu-2604/
