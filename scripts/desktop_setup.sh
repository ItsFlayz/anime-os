#!/bin/bash
set -e

echo "=========================================="
echo "    Anime OS - Desktop & GUI Setup        "
echo "=========================================="

ROOTFS_DIR="rootfs"

# ---------- Desktop + theming packages ----------
chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends \
    xorg xinit openbox tint2 feh lxterminal neofetch x11-xserver-utils \
    plymouth plymouth-themes \
    arc-theme papirus-icon-theme \
    lxappearance

# ---------- Security tools ----------
chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends \
    nmap netcat-openbsd tcpdump john hydra \
    wireshark tshark whois dnsutils \
    gnupg openssl macchanger

# ---------- Battery / performance tools (no kernel rebuild needed) ----------
chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends \
    tlp cpufrequtils powertop zram-tools

# enable tlp and zram at boot
chroot "$ROOTFS_DIR" systemctl enable tlp 2>/dev/null || true
chroot "$ROOTFS_DIR" systemctl enable zramswap 2>/dev/null || true

# ---------- Openbox autostart ----------
mkdir -p "$ROOTFS_DIR/etc/skel/.config/openbox"
cat << 'AUTOS_EOF' > "$ROOTFS_DIR/etc/skel/.config/openbox/autostart"
tint2 &
if [ -f /usr/share/backgrounds/anime.jpg ]; then
    feh --bg-scale /usr/share/backgrounds/anime.jpg &
else
    xsetroot -solid "#1e1e2e" &
fi
lxterminal &
AUTOS_EOF
chmod +x "$ROOTFS_DIR/etc/skel/.config/openbox/autostart"

# GTK theme + icons by default for every new user
mkdir -p "$ROOTFS_DIR/etc/skel/.config/gtk-3.0"
cat << 'GTK_EOF' > "$ROOTFS_DIR/etc/skel/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
GTK_EOF

echo "exec openbox-session" > "$ROOTFS_DIR/etc/skel/.xinitrc"
echo "neofetch 2>/dev/null" >> "$ROOTFS_DIR/etc/skel/.bashrc"

# ---------- Fix hostname (removes the "runnervmmprz5" / name resolution warning) ----------
echo "animeos" > "$ROOTFS_DIR/etc/hostname"
echo "127.0.0.1 localhost animeos" > "$ROOTFS_DIR/etc/hosts"

# ---------- Users ----------
chroot "$ROOTFS_DIR" bash -c 'echo "root:anime" | chpasswd'
chroot "$ROOTFS_DIR" bash -c 'useradd -m -s /bin/bash anime && echo "anime:anime" | chpasswd'
chroot "$ROOTFS_DIR" usermod -aG sudo,wireshark anime 2>/dev/null || true

echo "[+] Desktop, theme, security & power setup completed!"
