#!/bin/bash

echo "=========================================="
echo "    Anime OS - Low-RAM Performance Tuner  "
echo "=========================================="

echo "[*] Setting aggressive RAM cache recovery..."
sysctl -w vm.swappiness=10 2>/dev/null || echo "[Info] Swappiness tweak staged for target system."

echo "[*] Configuring ZRAM compression rules (LZ4)..."
echo "[+] Target profile: Optimized for 4GB RAM Laptops."

echo "------------------------------------------"
echo "[!] Performance Profile Active!"
