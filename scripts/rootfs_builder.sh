#!/bin/bash
set -e

echo "=========================================="
echo "    Anime OS - Real Rootfs Debootstrap    "
echo "=========================================="

ROOTFS_DIR="rootfs"
mkdir -p "$ROOTFS_DIR"

echo "[*] Bootstrapping minimal Debian Stable system..."
debootstrap --variant=minbase --arch=amd64 bookworm "$ROOTFS_DIR" http://deb.debian.org/debian/

echo "[*] Mounting virtual filesystems for chroot setup..."
mount --bind /dev "$ROOTFS_DIR/dev"
mount --bind /proc "$ROOTFS_DIR/proc"
mount --bind /sys "$ROOTFS_DIR/sys"

echo "[*] Installing core Linux Kernel & Live Boot Packages..."
chroot "$ROOTFS_DIR" apt-get update
chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends \
    linux-image-amd64 live-boot systemd-sysv

echo "[*] Cleaning up chroot mounts..."
umount "$ROOTFS_DIR/dev"
umount "$ROOTFS_DIR/proc"
umount "$ROOTFS_DIR/sys"

echo "[+] Base Debian Rootfs successfully built!"
