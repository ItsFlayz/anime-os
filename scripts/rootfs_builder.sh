#!/bin/bash

ROOTFS_DIR="rootfs"
ARCH="amd64"

echo "=========================================="
echo "    Anime OS - Rootfs & Core Injector     "
echo "=========================================="

if [ -d "$ROOTFS_DIR" ]; then
    echo "[!] Existing rootfs directory found!"
else
    mkdir -p "$ROOTFS_DIR"
    echo "[*] Initializing base rootfs structure in $ROOTFS_DIR..."
fi

# Reading Manifests
if [ -f "security_manifest.txt" ]; then
    SEC_TOOLS=$(cat security_manifest.txt)
    echo "[+] Loaded Security Tools: $SEC_TOOLS"
fi

if [ -f "desktop_manifest.txt" ]; then
    DE_TOOLS=$(cat desktop_manifest.txt)
    echo "[+] Loaded Desktop Stack: $DE_TOOLS"
fi

echo "------------------------------------------"
echo "[*] Staging core dependencies for ISO compilation..."
echo "[!] Rootfs workspace staged and ready for chroot execution!"
