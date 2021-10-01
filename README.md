# homelab

This is repository is a living wiki (when I forget) and a humble attempt of [IaC](https://docs.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code) for my experimental homelab.

- [homelab](#homelab)
- [Resources](#resources)
- [Devices](#devices)
  - [Intel NUC (NUC8i7BEH)](#intel-nuc-nuc8i7beh)
    - [Hardware](#hardware)
    - [Software](#software)
  - [PowerEdge r720xd](#poweredge-r720xd)
    - [Hardware](#hardware-1)
    - [Software](#software-1)

# Resources

Some great people made some great guides that I used:
- https://norocketscience.at/author/thomas/
- https://techno-tim.github.io/
- https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/
- https://gist.github.com/KrustyHack/fa39e509b5736703fb4a3d664157323f

# Devices

## Intel NUC (NUC8i7BEH)

### Hardware

- **CPU:** Intel i7-8559U (8) @ 4.50GHz
- **Memory:** Crucial 16GB DDR4-2666
- **Storage:**
  - Samsung 500GB SSD
    - Operating system & general purpose storage
  - Seagate IronWolf 4TB HDD (via Sabrant External Dock)
    - Plex Media & Shared Network Drive

### Software

- **OS:** Ubuntu Server 20.04
- **Containers (Docker):**
  - Plex
  - Jellyfin
  - Deluge BitTorrent Client
- **Systemd Units:**
  - Samba

## PowerEdge r720xd

### Hardware

- **CPU:** 2 x Intel Xeon (16) @ 2.50GHz
- **Memory:** 16 x Kingston 8GB DDR3-1600
- **Storage:**
  - **Physical:**
    - 9 x SATA Seagate Constellation 1TB HDD
    - 2 x SAS Seagate Constellation 1TB HDD
  - **Virtual:** via PERC H710 Controller
    - "OS": 1TB RAID-1 w/ SAS Drives
      - (Mirror) ~2x read speed, tolerant of 1 drive failure
      - For host & guest operating systems
    - "THICC": RAID-6
      - (Double parity) ~7x read speed, tolerant of 2 drive failures
      - For guest VM storage

### Software
- **OS:** Debian 11
- **Virtualization:** KVM (Proxmox)
  - `proxy`: Ubuntu, ([DDNS](https://github.com/timothymiller/cloudflare-ddns), [Nginx Proxy Manager](https://nginxproxymanager.com/))
- **Containers:** LXC
  - `pihole`: Ubuntu, [pihole](https://pi-hole.net/)
    - 1 CPU, 1GB ram, 6GB disk
  - `pivpn`: Ubuntu, [pivpn](https://pivpn.io/)
    - 1 CPU, 1GB ram, 6GB disk
  - `gh-runner-1`: Ubuntu, GitHub Actions self-hosted runner
    - 4 (shared) cores, 12GB ram, 16GB disk
  - `gh-runner-2`: Ubuntu, GitHub Actions self-hosted runner
    - 4 (shared) cores, 12GB ram, 16GB disk
