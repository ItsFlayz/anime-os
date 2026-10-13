#!/bin/bash
set -e

echo "=========================================="
echo "    Anime OS - Desktop & GUI Setup        "
echo "=========================================="

ROOTFS_DIR="rootfs"

chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends \
    xorg xinit openbox tint2 feh lxterminal neofetch

mkdir -p "$ROOTFS_DIR/etc/skel/.config/openbox"
cat << 'AUTOS_EOF' > "$ROOTFS_DIR/etc/skel/.config/openbox/autostart"
tint2 &
feh --bg-scale /usr/share/backgrounds/anime.jpg &
neofetch
AUTOS_EOF

chmod +x "$ROOTFS_DIR/etc/skel/.config/openbox/autostart"

echo "exec openbox-session" > "$ROOTFS_DIR/etc/skel/.xinitrc"

chroot "$ROOTFS_DIR" bash -c 'echo "root:anime" | chpasswd'
chroot "$ROOTFS_DIR" bash -c 'useradd -m -s /bin/bash anime && echo "anime:anime" | chpasswd'

echo "[+] Desktop & Customization setup completed!"
