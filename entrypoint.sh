#!/bin/sh
set -e

echo "[entrypoint] running as: $(id)"
echo "[entrypoint] opencode resolves to: $(id opencode)"

# Ensure XDG base directories exist for the opencode user
# Needed when /home/opencode is an empty volume mount on first start
for dir in \
  /home/opencode/.config/opencode \
  /home/opencode/.local/share/opencode \
  /home/opencode/.local/state/opencode \
  /home/opencode/.cache/opencode; do
  install -d -o opencode -g opencode "$dir" 2>/dev/null || true
done

if [ -n "$GITHUB_TOKEN" ]; then
  echo "[entrypoint] GITHUB_TOKEN detected — configuring git credential helper"
  su opencode -c 'git config --global credential.helper store'
  echo "https://opencode:${GITHUB_TOKEN}@github.com" > /home/opencode/.git-credentials
  chmod 600 /home/opencode/.git-credentials
  chown opencode:opencode /home/opencode/.git-credentials
  echo "[entrypoint] git credentials configured"
fi

chown -R opencode:opencode /workspace /home/opencode 2>&1 || echo "[entrypoint] WARNING: chown failed"

echo "[entrypoint] after chown:"
ls -ld /workspace /home/opencode

echo "[entrypoint] dropping to opencode and exec'ing: $*"
exec runuser -u opencode -- "$@"
