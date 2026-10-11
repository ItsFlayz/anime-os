#!/bin/bash
set -e

echo "=========================================="
echo "        Anime OS Custom ISO Builder       "
echo "=========================================="

BUILD_DIR="iso_build"
WORK_DIR="$BUILD_DIR/iso"
LIVE_DIR="$WORK_DIR/live"

mkdir -p "$LIVE_DIR" "$BUILD_DIR"

echo "[*] Step 1: Preparing live filesystem directories..."
if [ -d "rootfs" ]; then
    echo "[*] Step 2: Compressing filesystem into SquashFS..."
    mksquashfs rootfs "$LIVE_DIR/filesystem.squashfs" -e boot
else
    echo "[!] Creating empty live squashfs structure..."
    mkdir -p rootfs_temp
    mksquashfs rootfs_temp "$LIVE_DIR/filesystem.squashfs"
    rm -rf rootfs_temp
fi

echo "[*] Step 3: Compiling ISO Image via Xorriso..."
cat << 'ISOLINUX_EOF' > "$WORK_DIR/isolinux.cfg"
default animeos
label animeos
  kernel /live/vmlinuz
  append initrd=/live/initrd.img boot=live quiet
ISOLINUX_EOF

# Generate dummy ISO file inside iso_build directory
xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso-660-filenames \
  -volid "ANIME_OS" \
  -o "$BUILD_DIR/AnimeOS-v1.0-x86_64.iso" \
  "$WORK_DIR"

echo "[+] Target output ISO: $BUILD_DIR/AnimeOS-v1.0-x86_64.iso"
echo "[!] Builder environment completed successfully!"
