#!/bin/bash
set -euo pipefail

echo "=========================================="
echo "        Anime OS Custom ISO Builder       "
echo "=========================================="

ROOTFS="rootfs"
BUILD_DIR="iso_build"
WORK_DIR="$BUILD_DIR/iso"
LIVE_DIR="$WORK_DIR/live"
BOOT_DIR="$WORK_DIR/boot/grub"
ISO_OUT="$BUILD_DIR/AnimeOS-v1.0-x86_64.iso"

die() { echo "[!] ERROR: $*" >&2; exit 1; }
fsize() { stat -c %s "$1"; }

[ "$(id -u)" -eq 0 ] || die "Run as root (sudo ./scripts/iso_builder.sh)"
[ -d "$ROOTFS" ] || die "'$ROOTFS' not found. Run scripts/rootfs_builder.sh first."

echo "[*] Step 0: Checking rootfs is real..."
KERNEL=$(ls -1 "$ROOTFS"/boot/vmlinuz-* 2>/dev/null | sort -V | tail -n1 || true)
INITRD=$(ls -1 "$ROOTFS"/boot/initrd.img-* 2>/dev/null | sort -V | tail -n1 || true)
[ -n "$KERNEL" ] || die "No kernel in $ROOTFS/boot. Rootfs build did not finish."
[ -n "$INITRD" ] || die "No initrd in $ROOTFS/boot. Rootfs build did not finish."
echo "    kernel: $KERNEL"
echo "    initrd: $INITRD"

rm -rf "$WORK_DIR"
mkdir -p "$LIVE_DIR" "$BOOT_DIR"

echo "[*] Step 1: Copying kernel and initrd..."
cp -L "$KERNEL" "$LIVE_DIR/vmlinuz"
cp -L "$INITRD" "$LIVE_DIR/initrd.img"
[ "$(fsize "$LIVE_DIR/vmlinuz")" -gt 1000000 ] || die "vmlinuz is too small"
[ "$(fsize "$LIVE_DIR/initrd.img")" -gt 1000000 ] || die "initrd.img is too small"

echo "[*] Step 2: Compressing Rootfs into SquashFS..."
mksquashfs "$ROOTFS" "$LIVE_DIR/filesystem.squashfs" -comp xz -noappend -e boot
[ "$(fsize "$LIVE_DIR/filesystem.squashfs")" -gt 100000000 ] \
    || die "filesystem.squashfs is under 100 MB, rootfs looks empty"

echo "[*] Step 3: Creating GRUB Boot Configuration (Normal + Lite Mode)..."
cat << 'GRUB_EOF' > "$BOOT_DIR/grub.cfg"
set default=0
set timeout=5

insmod png
if background_image /boot/grub/splash.png; then
    set color_normal=white/black
    set color_highlight=magenta/black
fi

menuentry "Anime OS Live (x86_64)" {
    linux /live/vmlinuz boot=live quiet splash
    initrd /live/initrd.img
}

menuentry "Anime OS Live - Lite Mode (low RAM / old laptops)" {
    linux /live/vmlinuz boot=live quiet liteos
    initrd /live/initrd.img
}
GRUB_EOF

# simple dark GRUB background so the boot menu matches the theme (no external art needed)
if command -v convert >/dev/null 2>&1; then
    convert -size 1024x768 gradient:'#120014-#1e1e2e' "$BOOT_DIR/splash.png" || true
fi

echo "[*] Step 4: Compiling Bootable ISO Image..."
grub-mkrescue -o "$ISO_OUT" "$WORK_DIR"
[ "$(fsize "$ISO_OUT")" -gt 200000000 ] || die "ISO is suspiciously small"

echo "[+] ISO compilation successfully completed: $ISO_OUT"
ls -lh "$ISO_OUT"
sha256sum "$ISO_OUT"
