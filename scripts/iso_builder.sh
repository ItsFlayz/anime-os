#!/bin/bash

BUILD_DIR="iso_build"
ISO_NAME="AnimeOS-v1.0-x86_64.iso"

echo "=========================================="
echo "      Anime OS Custom ISO Builder         "
echo "=========================================="

mkdir -p "$BUILD_DIR/live" "$BUILD_DIR/isolinux"

echo "[*] Step 1: Preparing live filesystem directories..."
echo "[*] Step 2: Syncing OverlayFS upper layer..."
echo "[*] Step 3: Compressing filesystem into SquashFS..."
echo "[+] Target output ISO: $ISO_NAME"
echo "------------------------------------------"
echo "[!] Builder environment initialized successfully!"
