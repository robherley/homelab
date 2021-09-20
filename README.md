# homelab


- [homelab](#homelab)
- [Intel NUC (NUC8i7BEH)](#intel-nuc-nuc8i7beh)
  - [Hardware](#hardware)
  - [Software](#software)
- [PowerEdge r720xd](#poweredge-r720xd)
  - [Hardware](#hardware-1)
  - [Software](#software-1)

# Intel NUC (NUC8i7BEH)

- Static IP: `192.168.1.69`

## Hardware

- **CPU:** Intel i7-8559U (8) @ 4.50GHz
- **Memory:** Crucial 16GB DDR4-2666
- **Storage:**
  - Crucial P1 m.2 1TB SSD
    - Operating system & general purpose storage
  - Seagate IronWolf 4TB HDD (via Sabrant External Dock)
    - Plex Media & Shared Network Drive
  - OCZ Agility 3 128GB SSD
    - Not really used, just filling up space

## Software

- **OS:** Fedora Server 33
- **Containers (Docker):**
  - Deluge BitTorrent Client
  - 2 x Minecraft Servers
  - ? x Static nginx sites
- **Systemd Units:**
  - Plex
  - Samba

# PowerEdge r720xd

- iDRAC Static IP: `192.168.1.101`
- Proxmox Static IP: `192.168.1.200`

## Hardware

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

## Software
- **OS:** Debian 11
- **Virtualization:** KVM (Proxmox)
  - `landscape`: Ubuntu, canonical landscape for linux vm patching
    - 8 (shared) cores, 16GB ram, 24GB disk
  - `game-servers`: Windows 10, used for game servers
    - 16 (shared) cores, 16GB ram, 128GB disk
  - `networking`: Ubuntu, (DDNS, Nginx Proxy Manager, Tailscale)
    - 8 (shared) cores, 16GB ram, 128GB disk
  - `k3s`: Ubuntu, k3s cluster
    - 16 (shared) cores, 16GB ram, 128GB disk
  - `gh-runner-1`: Ubuntu, GitHub Actions self-hosted runner
    - 4 (shared) cores, 12GB ram, 24GB disk
  - `gh-runner-2`: Ubuntu, GitHub Actions self-hosted runner
    - 4 (shared) cores, 12GB ram, 24GB disk
