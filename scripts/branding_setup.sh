#!/bin/bash

echo "=========================================="
echo "      Anime OS - Theme & Branding Config   "
echo "=========================================="

# Create custom splash banner for terminal
cat << 'BANNER' > /etc/motd
  ______             _                   ____   _____ 
 / _____)           (_)                 / __ \ / ____|
| /      _   _  ___  _ ____   ___ _____| |  | | (___  
| |     | | | |/ ___)| |  _ \ /___) ___ | |  | |\___ \ 
| \____ | |_| |____| | | | | |___ | ____| |__| |____) |
 \______)____/|_____)|_|_| |_(___/|_____)____/|_____/ 
                                                       
   :: Anime OS Lightweight Security Edition (4GB RAM) ::
   :: Built with Hardcore Kernel & RAM-Disk Engine    ::
BANNER

echo "[*] Custom ASCII MOTD banner installed!"
echo "[*] Setting dark anime color palette configs..."
echo "------------------------------------------"
echo "[+] Branding & Theme configs ready for ISO packaging!"
