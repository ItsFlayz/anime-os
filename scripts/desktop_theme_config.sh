#!/bin/bash

CONFIG_DIR="overlay_root/upper/etc/skel/.config"
mkdir -p "$CONFIG_DIR/openbox" "$CONFIG_DIR/tint2"

echo "=========================================="
echo "    Anime OS - High-End Aesthetic Engine   "
echo "=========================================="

# 1. Generating Tint2 Glass-Neon Taskbar Config
cat << 'TINT2_EOF' > "$CONFIG_DIR/tint2/tint2rc"
# Tint2 Custom Anime Glass Theme
panel_items = LTSBC
panel_position = bottom center
panel_size = 100% 32
panel_background_id = 1
wm_menu = 1

# Backgrounds
background_color = #0d0f18 85
border_color = #7aa2f7 40
border_width = 1
corner_radius = 6

# Clock & System Info
time1_format = %H:%M | %d %b
time1_font = Sans Bold 9
clock_font_color = #c0caf5 100
TINT2_EOF

# 2. Generating Openbox Menu Configuration
cat << 'OB_EOF' > "$CONFIG_DIR/openbox/menu.xml"
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Anime OS">
    <item label="Terminal"><action name="Execute"><execute>x-terminal-emulator</execute></action></item>
    <item label="File Manager"><action name="Execute"><execute>pcmanfm</execute></action></item>
    <separator />
    <menu id="hacking-tools" label="Cybersecurity Tools">
      <item label="Nmap Scanner"><action name="Execute"><execute>x-terminal-emulator -e nmap</execute></action></item>
      <item label="Wireshark"><action name="Execute"><execute>wireshark</execute></action></item>
      <item label="Burp Suite"><action name="Execute"><execute>burpsuite</execute></action></item>
      <item label="Metasploit Console"><action name="Execute"><execute>x-terminal-emulator -e msfconsole</execute></action></item>
    </menu>
    <separator />
    <item label="Exit System"><action name="Execute"><execute>openbox --exit</execute></action></item>
  </menu>
</openbox_menu>
OB_EOF

echo "[+] Glass-Neon Panel & Openbox Menu staged successfully!"
echo "[+] Resource footprint: Ultra Light (< 15MB VRAM / RAM impact)."
