#!/bin/bash

show_dashboard() {
    clear
    echo "=========================================="
    echo "       ANIME OS - MASTER CONTROL PANEL    "
    echo "=========================================="
    echo "1. Manage Persistence Whitelist (OverlayFS)"
    echo "2. Build & Package Custom ISO"
    echo "3. Apply 4GB RAM & ZRAM Optimizations"
    echo "4. Update Hacking Tools Manifest"
    echo "5. Configure Openbox/LXDE GUI Stack"
    echo "6. Initialize Base Rootfs Workspace"
    echo "7. Run Stealth & Privacy Module"
    echo "8. Apply High-End Anime Theme & Ricing"
    echo "9. Exit Architect Dashboard"
    echo "=========================================="
    read -p "Select action [1-9]: " choice

    case $choice in
        1) ./scripts/persistence_manager.sh ;;
        2) ./scripts/iso_builder.sh ; read -p "Press Enter to return..." ;;
        3) ./scripts/ram_optimizer.sh ; read -p "Press Enter to return..." ;;
        4) ./scripts/security_toolkit.sh ; read -p "Press Enter to return..." ;;
        5) ./scripts/desktop_setup.sh ; read -p "Press Enter to return..." ;;
        6) ./scripts/rootfs_builder.sh ; read -p "Press Enter to return..." ;;
        7) ./scripts/stealth_mode.sh ; read -p "Press Enter to return..." ;;
        8) ./scripts/desktop_theme_config.sh ; read -p "Press Enter to return..." ;;
        9) echo "Exiting Dashboard. Good luck, Architect!" ; exit 0 ;;
        *) echo "Invalid option!" ; sleep 1 ;;
    esac
    show_dashboard
}

chmod +x scripts/*.sh
show_dashboard
