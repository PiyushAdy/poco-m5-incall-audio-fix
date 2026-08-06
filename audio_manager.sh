#!/bin/bash

# ANSI Color Codes for terminal UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directory paths
XML_DIR="XML_Files"
BACKUP_BASE_DIR="Backups"

# Target audio files list
TARGET_FILES=(
  "/vendor/etc/audio_param/SpeechVolParam.xml"
  "/vendor/etc/audio_param/SpeechVol_AudioParam.xml"
  "/vendor/etc/audio_param/PlaybackVolAna_AudioParam.xml"
  "/vendor/etc/audio_param/Speech_AudioParam.xml"
  "/vendor/etc/audio_param/SmartPa_AudioParam.xml"
  "/vendor/etc/audio_param/Volume_AudioParam.xml"
  "/vendor/etc/audio_policy_volumes.xml"
  "/vendor/etc/audio_device.xml"
  "/vendor/etc/audio_param/SpeechGeneral_AudioParam.xml"
  "/vendor/etc/audio_param/VoIP_AudioParam.xml"
  "/vendor/etc/audio_param/VoIPv2_AudioParam.xml"
  "/vendor/etc/audio_param/VoIPVol_AudioParam.xml"
  "/vendor/etc/audio_param/VoIPVolUI_AudioParam.xml"
)

# Function: Pre-flight checks and ADB Remounting
prepare_adb_remount() {
    echo -e "${CYAN}⏳ Waiting for device via ADB...${NC}"
    adb wait-for-device

    echo -e "${CYAN}🔓 Restarting ADB in root mode...${NC}"
    adb root >/dev/null 2>&1
    sleep 2
    adb wait-for-device

    echo -e "${CYAN}🔄 Remounting partitions as Read-Write...${NC}"
    REMOUNT_OUT=$(adb remount 2>&1)
    echo "$REMOUNT_OUT"

    # Handle overlayfs first-time remount reboot requirement
    if echo "$REMOUNT_OUT" | grep -iq "reboot"; then
        echo ""
        echo -e "${YELLOW}⚠️ REMOUNT REQUIRES A REBOOT${NC}"
        echo "Your ROM requires a one-time reboot to establish the read-write overlay filesystem."
        echo "Rebooting device now..."
        adb reboot
        echo ""
        echo -e "${RED}🚨 IMPORTANT: Wait for your device to reboot, unlock screen, and re-run this script!${NC}"
        exit 0
    fi
}

# Function: Pull files from live device to PC
backup_device_files() {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    CURRENT_BACKUP_DIR="$BACKUP_BASE_DIR/Backup_$TIMESTAMP"

    echo -e "${CYAN}💾 Copying current device files via 'adb pull' to PC...${NC}"
    mkdir -p "$CURRENT_BACKUP_DIR"

    PULLED_COUNT=0
    for file in "${TARGET_FILES[@]}"; do
        if adb pull "$file" "$CURRENT_BACKUP_DIR/" >/dev/null 2>&1; then
            PULLED_COUNT=$((PULLED_COUNT+1))
        fi
    done

    echo -e "${GREEN}✅ Backup complete! $PULLED_COUNT files saved to:${NC}"
    echo -e "   📂 $CURRENT_BACKUP_DIR"
    echo ""
}

# Function: Push fixed XMLs
flash_fixed_audio() {
    if [ ! -d "$XML_DIR" ]; then
        echo -e "${RED}❌ Error: '$XML_DIR' folder not found. Make sure you are running this from the repo folder.${NC}"
        exit 1
    fi

    # Always backup before flashing
    echo -e "${YELLOW}--- STEP 1: AUTOMATIC LOCAL BACKUP ---${NC}"
    backup_device_files

    echo -e "${YELLOW}--- STEP 2: FLASHING FIXED XMLs ---${NC}"
    for FILE_PATH in "$XML_DIR"/*.xml; do
        [ -e "$FILE_PATH" ] || { echo -e "${RED}❌ No XML files found in $XML_DIR!${NC}"; exit 1; }

        FILE_NAME=$(basename "$FILE_PATH")

        if [[ "$FILE_NAME" == "audio_policy_volumes.xml" || "$FILE_NAME" == "audio_device.xml" ]]; then
            DEST="/vendor/etc/$FILE_NAME"
        else
            DEST="/vendor/etc/audio_param/$FILE_NAME"
        fi

        echo -e "   -> Pushing $FILE_NAME to $DEST"
        adb push "$FILE_PATH" "$DEST"
        adb shell "chmod 644 $DEST && chown root:root $DEST"
    done

    echo ""
    echo -e "${GREEN}✅ Fixed audio files applied with correct permissions (644, root:root).${NC}"
    read -p "Reboot device now to apply changes? (y/N): " REBOOT_CHOICE
    if [[ "$REBOOT_CHOICE" =~ ^[Yy]$ ]]; then
        adb reboot
        echo -e "${GREEN}✨ Device rebooting!${NC}"
    fi
}

# Function: Restore selected backup
restore_backup_files() {
    if [ ! -d "$BACKUP_BASE_DIR" ] || [ -z "$(ls -A "$BACKUP_BASE_DIR" 2>/dev/null)" ]; then
        echo -e "${RED}❌ No local backups found in '$BACKUP_BASE_DIR/'.${NC}"
        return
    fi

    echo -e "${CYAN}Select a backup folder to restore to device:${NC}"
    PS3="Enter backup number: "
    options=("$BACKUP_BASE_DIR"/*/)

    select BACKUP_FOLDER in "${options[@]}"; do
        if [ -n "$BACKUP_FOLDER" ]; then
            echo -e "${YELLOW}Selected backup: $BACKUP_FOLDER${NC}"
            break
        else
            echo -e "${RED}Invalid selection.${NC}"
        fi
    done

    echo -e "${YELLOW}--- RESTORING BACKUP XMLs TO DEVICE ---${NC}"
    for FILE_PATH in "$BACKUP_FOLDER"*.xml; do
        [ -e "$FILE_PATH" ] || { echo -e "${RED}❌ No XML files found in this backup folder!${NC}"; exit 1; }

        FILE_NAME=$(basename "$FILE_PATH")

        if [[ "$FILE_NAME" == "audio_policy_volumes.xml" || "$FILE_NAME" == "audio_device.xml" ]]; then
            DEST="/vendor/etc/$FILE_NAME"
        else
            DEST="/vendor/etc/audio_param/$FILE_NAME"
        fi

        echo -e "   -> Restoring $FILE_NAME to $DEST"
        adb push "$FILE_PATH" "$DEST"
        adb shell "chmod 644 $DEST && chown root:root $DEST"
    done

    echo ""
    echo -e "${GREEN}✅ Original backup files restored with permissions (644, root:root).${NC}"
    read -p "Reboot device now to apply changes? (y/N): " REBOOT_CHOICE
    if [[ "$REBOOT_CHOICE" =~ ^[Yy]$ ]]; then
        adb reboot
        echo -e "${GREEN}✨ Device rebooting!${NC}"
    fi
}

# Main Interactive UI
clear
echo -e "${GREEN}==========================================================${NC}"
echo -e "${GREEN} 📱 POCO M5 (g99) In-Call Audio Fix & Backup Manager${NC}"
echo -e "${GREEN}==========================================================${NC}"
echo -e "⚠️  PREREQUISITES:"
echo -e " 1. Enable USB Debugging in Developer Options."
echo -e " 2. Enable 'Rooted Debugging' (ADB Root) in Developer Options."
echo -e " 3. If using KernelSU/Magisk, grant Root access to ADB Shell."
echo -e "=========================================================="
echo ""
echo -e "${CYAN}What would you like to do?${NC}"
echo " 1) Flash Fixed Audio XMLs (Auto-backups device first)"
echo " 2) Restore a Previous Backup to Device"
echo " 3) Backup Device Files Only (No changes made)"
echo " 4) Exit"
echo ""

read -p "Enter choice [1-4]: " CHOICE

case $CHOICE in
    1)
        prepare_adb_remount
        flash_fixed_audio
        ;;
    2)
        prepare_adb_remount
        restore_backup_files
        ;;
    3)
        echo -e "${CYAN}⏳ Waiting for device...${NC}"
        adb wait-for-device
        adb root >/dev/null 2>&1
        sleep 2
        backup_device_files
        ;;
    4)
        echo -e "${YELLOW}Exiting.${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option.${NC}"
        exit 1
        ;;
esac