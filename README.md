# POCO M5 In-Call & System Audio Fix

⭐ **If you find this module helpful, please consider leaving a Star on this repository!** ⭐

A comprehensive audio parameter calibration for the **POCO M5 (g99)** running Custom ROMs. 

Custom ROMs on the POCO M5 often suffer from notoriously low in-call volume and feeble speaker output. This modification carefully tunes MediaTek's hardware mixer gains, audio policy volume curves, and DSP FIR equalizers to safely unlock the device's true audio potential.

---

## 🚀 What's Fixed?

* **System Dialer (In-Call Volume):** Drastically boosts SIM call volume on both VoLTE and Non-VoLTE networks (tested on Jio and Vi).
* **Feeble Call Speaker (Handsfree):** Fixes the bug where enabling the speakerphone during a normal call results in abnormally quiet output.
* **VoIP Applications:**
  * Earpiece volume is properly boosted across all VoIP apps.
  * WhatsApp and Signal speakerphone modes are fully calibrated.
  * Telegram call volume is boosted (see known bugs below for minor quirks).
* **Hardware Speaker Cap:** Safely pushes the main speaker's Programmable Gain Amplifier (PGA) to its maximum hardware capacity for both media consumption and system sounds.

---

## 📱 Compatibility

* **Verified on:** Shakib's LineageOS 22 (Android 15)
* **Target Builds:**
  * Shakib's other Custom ROMs
  * Asmodeus's Android 16 builds
  * Picasso's Android 13 & Android 16 builds
* *Note: This module should theoretically work on any AOSP/Custom ROM for the POCO M5.*

---

## ⚡ Installation Instructions

You can install this fix using EITHER the **Magisk/KernelSU Module** (Recommended) OR the **ADB push script**. 
⚠️ **Do not use both.**

### Method A: Magisk / KernelSU Module (Recommended)

This is the safest and easiest way to apply the fix systemlessly.

1. Download the latest module zip from the Releases page: 
   👉 **[POCO_M5_Incall_Audio_Fix.zip](https://github.com/PiyushAdy/poco-m5-incall-audio-fix/releases/latest/download/POCO_M5_Incall_Audio_Fix.zip)**
2. Open your root manager (Magisk, KernelSU, or APatch).
3. Flash the `.zip` file as a module.
4. Reboot your device.

> **⚠️ Note for KernelSU / APatch Users:** 
> This module mounts modified configuration files directly to `/vendor/etc`. If you are using a modern root solution (like KernelSU Next) that does not have an inbuilt overlayfs mount metamodule, you **MUST** install a mount module (such as **Hybrid Mount**, **Magic Mount-rs**, or **meta-overlayfs**) first. Without a mount module, KernelSU will silently fail to inject the audio files!

---

### Method B: ADB Push (Linux / WSL)

If you prefer to manually write the files directly to your `/vendor` partition, you can use the included interactive bash script.

**Prerequisites:**
* USB Debugging is **ON**.
* Rooted Debugging (ADB Root) is **ON**.
* ADB shell has root access granted.

**Run the following in your terminal:**
```bash
# 1. Clone only the ADB files (ignores the Magisk module source code to save space)
git clone --filter=blob:none --sparse https://github.com/PiyushAdy/poco-m5-incall-audio-fix.git
cd poco-m5-incall-audio-fix
git sparse-checkout set audio_manager.sh XML_Files

# 2. Make the script executable
chmod +x audio_manager.sh

# 3. Launch the interactive installer
./audio_manager.sh
```

**Script Menu Options:**
* **Option 1 (Flash Fixed Audio XMLs):** Automatically pulls a fresh backup of your live device files to a local `Backups/` folder, remounts `/vendor` as read-write, pushes the fixed XML files, and sets the proper permissions.
* **Option 2 (Restore Previous Backup):** Lets you pick a saved backup folder from your PC and pushes those original files back to your device to revert the mod.
* **Option 3 (Backup Device Files Only):** Safely pulls your current live audio configuration without modifying your phone.

> *Note on First-Time Remounts:* Android 13+ overlayfs might ask for a reboot the very first time `adb remount` is triggered. If the script tells you a reboot is required, let the phone reboot, unlock it, and run `./audio_manager.sh` again.

---

## ⚠️ Known Bugs & Limitations

* **OEM Hardware Specific:** All EQ and gain profiles were aggressively tuned for the official, factory-provided POCO M5 earpiece and speaker hardware. **It has not been tested on aftermarket replacement parts and may cause clipping.**
* **Potential Audio Echo:** If you turn Telegram call volume to absolute maximum, the person on the other end might hear a very faint echo of their own voice. *(WhatsApp and Signal have been specifically tuned to prevent this loopback, but Telegram's internal audio processing can still pick up very feeble feedback at max volume).*
* **VoWiFi Calls:** While completely untested, the required configuration parameters for Wi-Fi calling are included in this patch and should theoretically benefit from the exact same volume boosts.
