#!/system/bin/sh
##########################################################################################
# POCO M5 Ultimate Audio Fix - boot-time mount verification
#
# Runs early in boot (post-fs-data stage, supported by both Magisk and
# KernelSU/APatch). Checks whether our vendor files actually got mounted
# and records the result to a log file + a readable system prop, since
# there is no way to verify a successful mount at *install* time - the
# mount itself only happens during boot.
##########################################################################################

MODDIR=${0%/*}

chcon -R u:object_r:vendor_configs_file:s0 $MODDIR/system/vendor/etc 2>/dev/null
find $MODDIR/system/vendor/etc -type d -exec chmod 755 {} + 2>/dev/null
find $MODDIR/system/vendor/etc -type f -exec chmod 644 {} + 2>/dev/null

LOG=/data/adb/poco_audio_fix_status.log
CHECK_FILE=/vendor/etc/audio_policy_volumes.xml
MARKER="100,1500"

mkdir -p /data/adb 2>/dev/null

if [ -f "$CHECK_FILE" ] && grep -q "$MARKER" "$CHECK_FILE" 2>/dev/null; then
  STATUS="MOUNTED_OK"
else
  STATUS="NOT_MOUNTED"
fi

{
  echo "[$(date)] POCO M5 Audio Fix mount check: $STATUS"
  if [ "$STATUS" = "NOT_MOUNTED" ]; then
    echo "  -> $CHECK_FILE does not contain the expected marker text."
    echo "  -> On KernelSU/APatch this usually means no mount metamodule"
    echo "     (meta-overlayfs / Hybrid Mount / Magic Mount-rs) is active,"
    echo "     or it failed to mount this module."
    echo "  -> On Magisk this may mean the module failed to install, is"
    echo "     disabled, or was overridden by another module."
  fi
} >> "$LOG" 2>/dev/null

# Expose status as a queryable prop:
#   adb shell getprop poco.audiofix.status
resetprop -n poco.audiofix.status "$STATUS" 2>/dev/null || setprop poco.audiofix.status "$STATUS" 2>/dev/null

log -t POCO_AUDIO_FIX "mount check: $STATUS" 2>/dev/null

exit 0
