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
    lxappearance kbd

# ---------- Everyday apps ----------
chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends \
    pcmanfm mousepad gpicview xarchiver htop rofi \
    network-manager-gnome blueman \
    yad sudo libnotify-bin imagemagick

# ---------- Security tools ----------
chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends \
    nmap netcat-openbsd tcpdump john hydra \
    wireshark tshark whois dnsutils \
    gnupg openssl macchanger

# ---------- Battery / performance tools ----------
chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends \
    tlp cpufrequtils powertop zram-tools

chroot "$ROOTFS_DIR" systemctl enable tlp 2>/dev/null || true
chroot "$ROOTFS_DIR" systemctl enable zramswap 2>/dev/null || true

# ---------- Procedural wallpapers (abstract neon gradients, no copyrighted art) ----------
mkdir -p "$ROOTFS_DIR/usr/share/backgrounds/animeos"
chroot "$ROOTFS_DIR" bash -c '
    convert -size 1920x1080 radial-gradient:"#ff2e9a-#120014" /usr/share/backgrounds/animeos/wall1.png
    convert -size 1920x1080 radial-gradient:"#7b2eff-#0a0014" /usr/share/backgrounds/animeos/wall2.png
    convert -size 1920x1080 gradient:"#00e5ff-#120014" /usr/share/backgrounds/animeos/wall3.png
    convert -size 1920x1080 gradient:"#ff2e9a-#1e1e2e" -rotate 45 -gravity center -crop 1920x1080+0+0 /usr/share/backgrounds/animeos/wall4.png
'

# ---------- AnimeOS Control Panel ----------
cat << 'CTRL_EOF' > "$ROOTFS_DIR/usr/local/bin/animeos-control"
#!/bin/bash
CHOICE=$(yad --title="Anime OS Control Panel" --width=320 --height=320 --list \
  --column=Action \
  "Performance Mode" \
  "Balanced Mode" \
  "Battery Saver Mode" \
  "Change Wallpaper" \
  "Open Theme Settings" \
  "Quick Security Scan (localhost)" \
  --button=Run:0 --button=Close:1 --no-headers)

ACTION=$(echo "$CHOICE" | sed 's/|$//')

case "$ACTION" in
  "Performance Mode")
      sudo cpupower frequency-set -g performance >/dev/null 2>&1
      notify-send "Anime OS" "Performance mode enabled" 2>/dev/null
      ;;
  "Balanced Mode")
      sudo cpupower frequency-set -g ondemand >/dev/null 2>&1
      notify-send "Anime OS" "Balanced mode enabled" 2>/dev/null
      ;;
  "Battery Saver Mode")
      sudo cpupower frequency-set -g powersave >/dev/null 2>&1
      notify-send "Anime OS" "Battery saver enabled" 2>/dev/null
      ;;
  "Change Wallpaper")
      feh --bg-scale "$(find /usr/share/backgrounds/animeos -type f | shuf -n1)"
      ;;
  "Open Theme Settings")
      lxappearance &
      ;;
  "Quick Security Scan (localhost)")
      lxterminal -e bash -c "nmap -sT 127.0.0.1; echo; read -p 'Press Enter to close...'"
      ;;
esac
CTRL_EOF
chmod +x "$ROOTFS_DIR/usr/local/bin/animeos-control"

mkdir -p "$ROOTFS_DIR/usr/share/applications"
cat << 'DESKTOP_EOF' > "$ROOTFS_DIR/usr/share/applications/animeos-control.desktop"
[Desktop Entry]
Name=Anime OS Control Panel
Exec=animeos-control
Type=Application
Categories=Settings;
DESKTOP_EOF

# allow the 'anime' user to change CPU/power settings without a password prompt
mkdir -p "$ROOTFS_DIR/etc/sudoers.d"
cat << 'SUDO_EOF' > "$ROOTFS_DIR/etc/sudoers.d/animeos-control"
anime ALL=(root) NOPASSWD: /usr/bin/cpupower, /usr/sbin/tlp
SUDO_EOF
chmod 440 "$ROOTFS_DIR/etc/sudoers.d/animeos-control"

# ---------- Openbox autostart (checks for Lite Mode via kernel cmdline) ----------
mkdir -p "$ROOTFS_DIR/etc/skel/.config/openbox"
cat << 'AUTOS_EOF' > "$ROOTFS_DIR/etc/skel/.config/openbox/autostart"
tint2 &
nm-applet &

if grep -qw liteos /proc/cmdline; then
    # Lite Mode: skip Bluetooth tray + image wallpaper to save RAM
    xsetroot -solid "#1e1e2e" &
else
    blueman-applet &
    feh --bg-scale "$(find /usr/share/backgrounds/animeos -type f | shuf -n1)" &
fi

lxterminal &
AUTOS_EOF
chmod +x "$ROOTFS_DIR/etc/skel/.config/openbox/autostart"

# ---------- Openbox keybindings: Super+Space = app launcher, Super+C = control panel ----------
mkdir -p "$ROOTFS_DIR/etc/xdg/openbox"
if [ -f "$ROOTFS_DIR/etc/xdg/openbox/rc.xml" ]; then
    sed -i 's#<keyboard>#<keyboard>\n  <keybind key="W-space"><action name="Execute"><command>rofi -show drun</command></action></keybind>\n  <keybind key="W-c"><action name="Execute"><command>animeos-control</command></action></keybind>#' \
        "$ROOTFS_DIR/etc/xdg/openbox/rc.xml"
fi

# GTK theme + icons by default for every new user
mkdir -p "$ROOTFS_DIR/etc/skel/.config/gtk-3.0"
cat << 'GTK_EOF' > "$ROOTFS_DIR/etc/skel/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
GTK_EOF

echo "exec openbox-session" > "$ROOTFS_DIR/etc/skel/.xinitrc"
echo "neofetch --config animeos 2>/dev/null" >> "$ROOTFS_DIR/etc/skel/.bashrc"

mkdir -p "$ROOTFS_DIR/etc/skel/.config/neofetch"
cat << 'NF_EOF' > "$ROOTFS_DIR/etc/skel/.config/neofetch/animeos"
print_info() {
    info title
    info underline
    info "OS" distro
    info "Kernel" kernel
    info "Uptime" uptime
    info "Shell" shell
    info "CPU" cpu
    info "Memory" memory
}
ascii_distro="Debian"
colors=(5 1 6 2 7 7)
NF_EOF

# ---------- Auto-login on tty1 + auto-start desktop (real console only, not serial/CI) ----------
mkdir -p "$ROOTFS_DIR/etc/systemd/system/getty@tty1.service.d"
cat << 'AUTOLOGIN_EOF' > "$ROOTFS_DIR/etc/systemd/system/getty@tty1.service.d/autologin.conf"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin anime --noclear %I $TERM
AUTOLOGIN_EOF

cat << 'PROFILE_EOF' >> "$ROOTFS_DIR/etc/skel/.bash_profile"
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
PROFILE_EOF

# ---------- Fix hostname ----------
echo "animeos" > "$ROOTFS_DIR/etc/hostname"
echo "127.0.0.1 localhost animeos" > "$ROOTFS_DIR/etc/hosts"

# ---------- Users ----------
chroot "$ROOTFS_DIR" bash -c 'echo "root:anime" | chpasswd'
chroot "$ROOTFS_DIR" bash -c 'useradd -m -s /bin/bash anime && echo "anime:anime" | chpasswd'
chroot "$ROOTFS_DIR" usermod -aG sudo,wireshark anime 2>/dev/null || true

echo "[+] Desktop, theme, control panel, wallpapers & power setup completed!"
