export ANSIBLE_FORCE_COLOR := "1"
export ANSIBLE_CONFIG := justfile_directory() / "ansible/ansible.cfg"
export PROXMOX_TOKEN_SECRET := "op://Homelab/Proxmox-Scripts/token_secret"

# Configure development environment
bootstrap:
    brew bundle

# Run an ansible playbook by name, e.g. `just ansible harden-ssh -- --limit foo`
ansible name *args:
    op run -- ansible-playbook ansible/playbooks/{{name}}.yml {{args}}
