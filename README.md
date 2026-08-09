# POCO M5 In-Call & System Audio Fix

A comprehensive audio parameter fix for the **POCO M5 (g99)** running Custom ROMs. This mod tunes MediaTek's hardware mixer gains, audio policy volume curves, and DSP FIR equalizers to fix the notorious low in-call volume and feeble speaker sound.

⭐ **If you find this module helpful, please consider leaving a Star on this repository!** ⭐

---

## 🚀 What This Fixes

* **In-Call Volume (System Dialer):** Drastically improves and boosts SIM call volume on both VoLTE and Non-VoLTE SIMs.
* *Tested on Shakib's LineageOS 22 (Android 15) using Jio (VoLTE), Vi (VoLTE), and Vi (Non-VoLTE).*


* **Feeble Call Speaker / Handsfree Mode:** Fixes the issue where turning on speakerphone during a normal call still sounds way too quiet.
* **VoIP App Calls (Earpiece & Speaker):** Fixes low volume during calls on WhatsApp, Signal, and Telegram.
* Earpiece volume is properly boosted across all VoIP apps.
* WhatsApp and Signal speakerphone modes are fully tuned and fixed.
* Telegram call volume is fixed, though it has a minor quirk noted below.


* **Maximum Hardware Speaker Boost:** Safely pushes the main speaker's Programmable Gain Amplifier (PGA) to its max hardware capacity for media and calls.
* **Safe Installation:** Operates with an interactive installer that automatically pulls and saves a local backup of your device's original XML files to your PC before pushing any edits.

---

## 📱 Compatibility

* **Tested & Verified:** Shakib's Android 15 LineageOS
* **Target Builds:**
* Asmodeus's Android 16 builds
* Picasso's Android 13 & Android 16 builds
* *Ideally works across all custom ROMs for POCO M5.*



---

## 🛠️ Prerequisites

Before running the installer, make sure:

1. **USB Debugging** is turned **ON** in Developer Options.
2. **Rooted Debugging (ADB Root)** is turned **ON** in Developer Options.
3. If you are using **KernelSU** or **Magisk**, make sure root access is granted to the ADB shell.

---

## ⚡ How to Use

You can install this fix using EITHER the **ADB method** OR the **Magisk/KernelSU Module method**. **Do not use both.**

### Method A: Magisk / KernelSU Module (Recommended)

1. Download the latest module zip from the Releases page: [POCO_M5_Incall_Audio_Fix.zip](https://github.com/PiyushAdy/poco-m5-incall-audio-fix/releases/latest/download/POCO_M5_Incall_Audio_Fix.zip)
2. Open Magisk, KernelSU, or APatch.
3. Flash the module and reboot.

> **Note for KernelSU / APatch Users:** This module mounts files to `/vendor/etc`. If you are using a newer KernelSU (e.g. KernelSU Next) that does not have an inbuilt overlayfs mount metamodule, you **MUST** install a mount module like **Hybrid Mount**, **Magic Mount-rs**, or **meta-overlayfs** first. Without it, KernelSU will silently fail to mount the vendor files.

### Method B: ADB Push (Linux / WSL)

Open your Linux terminal (Fedora, Ubuntu, Arch, etc.) or WSL on Windows and run:

```bash
# 1. Clone the repository
git clone https://github.com/PiyushAdy/poco-m5-incall-audio-fix.git

# 2. Enter the directory
cd poco-m5-incall-audio-fix

# 3. Make the script executable
chmod +x audio_manager.sh

# 4. Run the interactive menu
./audio_manager.sh

```

### Menu Options Inside `audio_manager.sh`:

* **Option 1 (Flash Fixed Audio XMLs):** Automatically pulls a fresh backup of your live device files to a `Backups/` folder on your PC, remounts `/vendor` as read-write, pushes the fixed XML files, and sets proper `644 root:root` permissions.
* **Option 2 (Restore Previous Backup):** Lets you pick any saved backup folder from your PC and pushes those original files back to your device.
* **Option 3 (Backup Device Files Only):** Pulls the current live audio configuration without modifying anything on your phone.

> **Note on First-Time Remounts:** Android 13+ overlayfs might ask for a reboot the very first time `adb remount` is triggered. If the script tells you a reboot is required, let the phone reboot, unlock it, and run `./audio_manager.sh` again to finish.

---

## ⚠️ Known Bugs & Things to Look Out For

* **OEM Hardware Specific:** All EQ and gain profiles were tuned and tested on the official factory-provided earpiece and speaker hardware. **It has not been tested on aftermarket replacement parts.**
* **Potential Audio Feedback / Echo:** If you are using cheap aftermarket replacement speakers/microphones, or if you turn Telegram call volume to maximum , the person on the other end might hear a very faint echo of their own voice. *WhatsApp and Signal have been specifically tuned to prevent this on official factory-provided earpiece, but Telegram's internal audio processing can still pick up very feeble loopback at max volume.*
* **VoWiFi Calls:** Untested directly, but the required configuration parameters for Wi-Fi calling are included and should benefit from the same volume boost.
