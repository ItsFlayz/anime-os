#!/bin/bash
set -e

echo "=========================================="
echo "    Anime OS - Security Toolkit           "
echo "=========================================="

ROOTFS_DIR="rootfs"

# Install security tools
chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends \
    nmap wireshark tshark aircrack-ng curl wget net-tools

echo "[+] Security tools installed successfully!"
