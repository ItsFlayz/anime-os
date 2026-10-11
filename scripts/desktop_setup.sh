#!/bin/bash
set -e

echo "=========================================="
echo "    Anime OS - Desktop & GUI Setup        "
echo "=========================================="

ROOTFS_DIR="rootfs"

# Install Openbox GUI, Tint2 panel, Feh (wallpaper manager) & Terminal
chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends \
    xorg openbox tint2 feh lxterminal neofetch

# Setup default wallpaper & autostart configs
mkdir -p "$ROOTFS_DIR/etc/skel/.config/openbox"
cat << 'AUTOS_EOF' > "$ROOTFS_DIR/etc/skel/.config/openbox/autostart"
tint2 &
feh --bg-scale /usr/share/backgrounds/anime.jpg &
neofetch
AUTOS_EOF

chmod +x "$ROOTFS_DIR/etc/skel/.config/openbox/autostart"

echo "[+] Desktop & Customization setup completed!"
