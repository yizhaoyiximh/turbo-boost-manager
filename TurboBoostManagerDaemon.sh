#!/bin/sh

DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

# Disable Turbo Boost at daemon startup, then keep it disabled after wake events.
"$DIR/TurboBoostManager.sh" 3
exec "$DIR/TurboBoostManager.sh" 0
