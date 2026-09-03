#!/bin/sh

set -eu

LABEL="com.psychowood.turboboostmanager"
PLIST_PATH="/Library/LaunchDaemons/$LABEL.plist"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
DAEMON_SCRIPT="$SCRIPT_DIR/TurboBoostManagerDaemon.sh"
TMP_PLIST="$(mktemp -t "$LABEL").plist"

cleanup() {
    rm -f "$TMP_PLIST"
}
trap cleanup EXIT INT TERM

if [ "$(uname -s)" != "Darwin" ]; then
    echo "This script must be run on macOS." >&2
    exit 1
fi

case "$SCRIPT_DIR" in
    *'&'*|*'<'*|*'>')
        echo "The project path cannot contain &, <, or >." >&2
        exit 1
        ;;
esac

if [ ! -x "$DAEMON_SCRIPT" ]; then
    echo "Missing executable: $DAEMON_SCRIPT" >&2
    echo "Run: chmod 755 TurboBoostManagerDaemon.sh" >&2
    exit 1
fi

cat > "$TMP_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$DAEMON_SCRIPT</string>
    </array>
    <key>WorkingDirectory</key>
    <string>$SCRIPT_DIR</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/turboboostmanager.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/turboboostmanager.err</string>
</dict>
</plist>
EOF

plutil -lint "$TMP_PLIST" >/dev/null
chmod 755 "$DAEMON_SCRIPT"

echo "Installing $PLIST_PATH"
sudo launchctl unload "$PLIST_PATH" 2>/dev/null || true
sudo install -o root -g wheel -m 644 "$TMP_PLIST" "$PLIST_PATH"
sudo launchctl load "$PLIST_PATH"

echo "Turbo Boost Manager is configured and loaded."
echo "Project path: $SCRIPT_DIR"
echo "Logs: /var/log/turboboostmanager.log and /var/log/turboboostmanager.err"
