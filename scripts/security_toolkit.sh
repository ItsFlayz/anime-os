#!/bin/bash

echo "=========================================="
echo "    Anime OS - Security Toolkit Installer "
echo "=========================================="

echo "[*] Selecting lightweight pentest & networking utilities..."

TOOL_LIST="nmap netcat-openbsd tcpdump dnsutils curl wget git"

echo "[+] Target tools to bundle: $TOOL_LIST"
echo "[*] Generating pre-flight installation manifest..."

# Writing tools to a config file for ISO builder to grab later
echo "$TOOL_LIST" > security_manifest.txt

echo "------------------------------------------"
echo "[+] Security manifest locked successfully!"
echo "[!] These tools will be baked into your custom ISO."
