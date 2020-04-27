sudo su -
ip link show
wpa_supplicant -B -i <interface> -c <(wpa_passphrase '<ssid>' '<password>')
systemctl restart wpa_supplicant
ip addr
lsblk
wipefs -a /dev/nvme0n1
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 1 boot on
parted /dev/nvme0n1 -- mkpart primary linux-swap 512MiB 3.5GiB
parted /dev/nvme0n1 -- mkpart primary ext4 3.5GiB 100%

# Documentation has 'boot'
# Will throw an error if 'boot' instead of 'BOOT'
# Needs to be BOOT to be DOS and Windows compatible
# BOOT will also supress the warning thrown about
# DOS and Windows compatibility
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1

mkswap -L swap /dev/nvme0n1p2
mkfs.ext4 -L nixos /dev/nvme0n1p3
mount /dev/disk/by-label/nixos /mnt

# Must be /boot, lowercase, so the installation
# doesn't fail
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot

swapon /dev/nvme0n1p2
nixos-generate-config --root /mnt

# Edit the config as needed
nano /mnt/etc/nixos/configuration.nix

nixos-install

reboot
