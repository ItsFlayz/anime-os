#!/bin/bash

echo "=========================================="
echo "  Anime OS - Lightweight DE Config (Openbox/LXDE)"
echo "=========================================="

echo "[*] Selecting lightweight display server & desktop packages..."

# Lightweight packages for 4GB RAM hardware
DE_PACKAGES="xorg openbox lxde-core lightdm tint2 pcmanfm obconf"

echo "[+] Target Desktop Stack: $DE_PACKAGES"
echo "$DE_PACKAGES" > desktop_manifest.txt

echo "------------------------------------------"
echo "[+] Openbox/LXDE manifest locked successfully!"
echo "[!] GUI environment will be baked into the ISO."
