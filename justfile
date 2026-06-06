export ANSIBLE_FORCE_COLOR := "1"
export ANSIBLE_CONFIG := justfile_directory() / "ansible/ansible.cfg"
export PROXMOX_TOKEN_SECRET := "op://Homelab/Proxmox-Scripts/token_secret"

# Configure development environment
bootstrap:
    brew bundle

# Run an ansible playbook by name, e.g. `just ansible harden-ssh -- --limit foo`
ansible name *args:
    op run -- ansible-playbook ansible/playbooks/{{name}}.yml {{args}}

# Terraform a workspace: `just tf proxmox plan`, `just tf vercel apply`.
# Secrets assembled with `op read` (op run can't resolve a secret embedded in a string).
tf workspace *args:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{workspace}}" in
      proxmox)
        tok="$(op read 'op://Homelab/Proxmox-Scripts/token_secret')"
        img_user="$(op read 'op://Homelab/Image-User/username')"
        img_hash="$(op read 'op://Homelab/Image-User/password_hash')"
        export PROXMOX_VE_API_TOKEN="scripts@pve!scripts=$tok"
        export TF_VAR_img_username="$img_user"
        export TF_VAR_img_password_hash="$img_hash"
        ;;
      vercel)
        vtok="$(op read 'op://Homelab/vercel/password')"
        export VERCEL_API_TOKEN="$vtok"
        ;;
      *)
        echo "unknown workspace '{{workspace}}'" >&2; exit 1 ;;
    esac
    terraform -chdir="terraform/{{workspace}}" {{args}}
