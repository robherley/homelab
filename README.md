# homelab

This is repository is a living wiki (when I forget) and a humble attempt of [IaC](https://docs.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code) for my experimental homelab.

- [homelab](#homelab)
- [Resources](#resources)
- [Hardware](#hardware)
- [Hacks](#hacks)
  - [Flashing RAID controller](#flashing-raid-controller)
  - [LSI and Seagate headache](#lsi-and-seagate-headache)
  - [Loud JBOD](#loud-jbod)
  - [Drive caddies](#drive-caddies)

# Resources

Some awesome people made some great guides that I used:
- https://norocketscience.at/author/thomas/
- https://techno-tim.github.io/
- https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/
- https://gist.github.com/KrustyHack/fa39e509b5736703fb4a3d664157323f

# Hardware

- [Dell Poweredge r720xd](https://www.dell.com/en-us/work/shop/productdetailstxn/poweredge-r720xd)
  - **CPU:** 2 x Intel Xeon (16) @ 2.50GHz
  - **Memory:** 16 x Kingston 8GB DDR3-1600
  - **Storage:**
    - 1 x SATA Samsung Evo 850 500GB SSD
    - 2 x SATA Crucial MX500 1TB SSD
    - 9 x SATA Seagate Constellation 1TB HDD
    - 2 x SAS Seagate Constellation 1TB HDD
- [Intel NUCi7BEH](https://www.intel.com/content/www/us/en/products/sku/126140/intel-nuc-kit-nuc8i7beh/specifications.html)
  - **CPU:** Intel i7-8559U (8) @ 4.50GHz
  - **Memory:** Mixed 32GB (16x2) DDR4-2666
  - **Storage:**
    - Crucial m.2 1TB SSD
- [Intel 2000 Family JBOD](https://www.intel.com/content/dam/support/us/en/documents/server-products/server-systems/JBOD%20HWG_v.1.42.pdf)
  - Connected to r720xd via Intel LSI HBA.
  - **Storage:** (Total capacity of 12 drives)
    - 4 x Seagate IronWolf 4TB NAS HDD
- [Raspberry Pi 3 Model B](https://www.raspberrypi.com/products/raspberry-pi-3-model-b/)
  - **CPU:** Quad Core 1.2GHz Broadcom BCM2837
  - **Memory:** 1GB RAM
  - **Storage:**
    - 8GB Micro SDHC
- All sitting in a [Startech 12U rack](https://www.startech.com/en-us/server-management/4postrack12u) next to my desk.

Unfortunately, I do not have dedicated networking hardware yet (stalking some UDM Pros on eBay). So for now, I'm just using the Verizon G3100 router.

# Hacks

## Flashing RAID controller

For my homelab, I decided to go with software-based RAID, specifically zfs. Primarily this decision was for learning reasons, but also it was for flexiblity with the hardware I currently have (ie: using a standalone SSD for a boot drive). So to achieve this flexibility, I followed the amazing guide from the folks at [Fohdeesha](https://fohdeesha.com/docs/perc.html) to flash the firmware on the PERC H710 controller to IT mode. This'll let me use each drive individually, without the requirement of virtual disks in a RAID configuration on the r720xd.

## LSI and Seagate headache

Luckily, the Intel branded LSI controller used as an HBA can be configured in JBOD mode, so it did not require any flashing to connect the r720xd and the Seagate drives. But, when testing some zpools I noticed a tremendous amount of `blk_update_request` I/O errors from the kernel. Turns out, there's a spinup/down issue with the Seagate Ironwolf drives and some LSI controllers being used, when they go into standby mode it takes a bit for them to spin up, resulting in the `blk_update_request` I/O errors I was seeing in the kernel. First fix attempt was to force some settings in [`hdparm`](https://wiki.archlinux.org/title/Hdparm): disabling the standby timeout (`hdparm -S 0 <disk>`) and the advance power management setting (`hdparm -B 255 <disk>`).

Seagate also has a special management utility called SeaChest, I followed [this guide](https://forums.unraid.net/topic/103938-69x-lsi-controllers-ironwolf-disks-disabling-summary-fix/)
from a user on the Unraid forum. Within that guide, there'll be instructions to disable EPC and low current spinup, which helped users resolve the drive issues.

## Loud JBOD

This entire rack is next to my desk, so reducing the amount of noise it makes is pretty important. At idle, the r720 is suprisingly quiet, whereas the Intel JBOD consistently sounds like a jet engine. So, I grabbed my soldering iron, some wire cutters and three of Noctua's [NF-A6x25](https://noctua.at/en/nf-a6x25-pwm)'s. They are the roughly the same size, PWM layout and voltage as the stock Nidec Ultraflo fans. They have noticibly less airflow, but with only 4 drives in the JBOD they manage to stay nice and cool.

## Drive caddies

Unfortunately I didn't have any of the OEM Dell drive caddies for the 3 SSDs I'm installing into the poweredge. Luckily, [someone on thingiverse](https://www.thingiverse.com/thing:2491236/) made these really sweet models that resememble mini versions of the poweredge.