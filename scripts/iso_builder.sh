#!/bin/bash
set -e

echo "=========================================="
echo "        Anime OS Custom ISO Builder       "
echo "=========================================="

BUILD_DIR="iso_build"
WORK_DIR="$BUILD_DIR/iso"
LIVE_DIR="$WORK_DIR/live"
BOOT_DIR="$WORK_DIR/isolinux"

mkdir -p "$LIVE_DIR" "$BOOT_DIR" "$BUILD_DIR"

echo "[*] Step 1: Preparing live filesystem structure..."
if [ -d "rootfs" ]; then
    echo "[*] Compressing rootfs into SquashFS..."
    mksquashfs rootfs "$LIVE_DIR/filesystem.squashfs" -comp xz -e boot
else
    echo "[!] Creating base squashfs container..."
    mkdir -p rootfs_temp
    mksquashfs rootfs_temp "$LIVE_DIR/filesystem.squashfs"
    rm -rf rootfs_temp
fi

echo "[*] Step 2: Configuring ISOLINUX bootloader..."
cat << 'ISOLINUX_EOF' > "$BOOT_DIR/isolinux.cfg"
UI menu.c32
PROMPT 0
TIMEOUT 50
DEFAULT animeos

LABEL animeos
  MENU LABEL Anime OS Live (x86_64)
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd.img boot=live quiet
ISOLINUX_EOF

# Copy isolinux binaries if available
if [ -f "/usr/lib/ISOLINUX/isolinux.bin" ]; then
    cp /usr/lib/ISOLINUX/isolinux.bin "$BOOT_DIR/"
    cp /usr/lib/syslinux/modules/bios/*.c32 "$BOOT_DIR/" 2>/dev/null || true
fi

echo "[*] Step 3: Compiling ISO with Xorriso..."
xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso-660-filenames \
  -volid "ANIME_OS" \
  -o "$BUILD_DIR/AnimeOS-v1.0-x86_64.iso" \
  "$WORK_DIR"

echo "[+] Target output ISO generated at: $BUILD_DIR/AnimeOS-v1.0-x86_64.iso"
