#!/bin/bash

WHITELIST="persistence_whitelist.txt"

# Default Whitelist Setup
if [ ! -f "$WHITELIST" ]; then
    echo "/home/user/Desktop" > "$WHITELIST"
    echo "/home/user/Documents" >> "$WHITELIST"
    echo "/etc/anime_os_config" >> "$WHITELIST"
fi

show_menu() {
    clear
    echo "=========================================="
    echo "   Anime OS - Persistence Exclusion Manager"
    echo "=========================================="
    echo "Current Whitelisted Paths (Saved on Reboot):"
    echo "------------------------------------------"
    if [ -s "$WHITELIST" ]; then
        nl -w2 -s'. ' "$WHITELIST"
    else
        echo " [!] Whitelist is empty! Everything will be wiped on reboot."
    fi
    echo "------------------------------------------"
    echo "1. Add a path/folder to Whitelist"
    echo "2. Remove a path from Whitelist"
    echo "3. Clear Whitelist (Full Ephemeral / RAM Mode)"
    echo "4. Exit"
    echo "=========================================="
    read -p "Choose an option [1-4]: " choice

    case $choice in
        1)
            read -p "Enter full path to persist (e.g., /home/user/Downloads): " new_path
            if [ -n "$new_path" ]; then
                echo "$new_path" >> "$WHITELIST"
                echo "[+] Added: $new_path"
            fi
            sleep 1.5
            show_menu
            ;;
        2)
            read -p "Enter line number to remove: " line_num
            if [ -n "$line_num" ]; then
                sed -i "${line_num}d" "$WHITELIST"
                echo "[-] Line $line_num removed."
            fi
            sleep 1.5
            show_menu
            ;;
        3)
            > "$WHITELIST"
            echo "[!] Whitelist cleared! OS is now in pure RAM mode."
            sleep 1.5
            show_menu
            ;;
        4)
            echo "Exiting Persistence Manager..."
            exit 0
            ;;
        *)
            echo "Invalid option!"
            sleep 1
            show_menu
            ;;
    esac
}

show_menu
