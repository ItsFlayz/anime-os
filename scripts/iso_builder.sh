#!/bin/bash
set -e

echo "=========================================="
echo "        Anime OS Custom ISO Builder       "
echo "=========================================="

BUILD_DIR="iso_build"
WORK_DIR="$BUILD_DIR/iso"
LIVE_DIR="$WORK_DIR/live"
BOOT_DIR="$WORK_DIR/boot/grub"

mkdir -p "$LIVE_DIR" "$BOOT_DIR"

echo "[*] Step 1: Compressing Rootfs into SquashFS..."
if [ -d "rootfs" ]; then
    mksquashfs rootfs "$LIVE_DIR/filesystem.squashfs" -comp xz -e boot
else
    mkdir -p rootfs_temp
    mksquashfs rootfs_temp "$LIVE_DIR/filesystem.squashfs"
    rm -rf rootfs_temp
fi

echo "[*] Step 2: Creating GRUB Boot Configuration..."
cat << 'GRUB_EOF' > "$BOOT_DIR/grub.cfg"
set default=0
set timeout=5

menuentry "Anime OS Live (x86_64)" {
    linux /live/vmlinuz boot=live quiet
    initrd /live/initrd.img
}
GRUB_EOF

cp -L "$(ls rootfs/boot/vmlinuz-* | sort -V | tail -n1)" "$LIVE_DIR/vmlinuz"
cp -L "$(ls rootfs/boot/initrd.img-* | sort -V | tail -n1)" "$LIVE_DIR/initrd.img"

echo "[*] Step 3: Compiling Bootable ISO Image..."
grub-mkrescue -o "$BUILD_DIR/AnimeOS-v1.0-x86_64.iso" "$WORK_DIR"

echo "[+] ISO compilation successfully completed: $BUILD_DIR/AnimeOS-v1.0-x86_64.iso"
