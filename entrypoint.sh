#!/bin/sh
set -e

# Unraid (and Docker in general) auto-creates missing bind-mount host
# directories as root, but we run opencode as a non-root user. Fix
# ownership on the mount points here (as root, before dropping privileges)
# so it self-heals regardless of who created them on the host side.
chown opencode:opencode /workspace 2>/dev/null || true
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"
chown -R opencode:opencode "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"

exec runuser -u opencode -- "$@"
