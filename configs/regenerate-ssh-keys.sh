#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

SSH_KEYS_DIR="/var/repo/.sshkeys"

# Regenerate when directory is missing or empty
if [ ! -d "$SSH_KEYS_DIR" ] || [ -z "$(ls -A "$SSH_KEYS_DIR" 2>/dev/null)" ]; then
    echo '==> Regenerating SSH host keys...'
    mkdir -p "$SSH_KEYS_DIR"

    # check writability
    if [ ! -w "$SSH_KEYS_DIR" ]; then
        echo "ERROR: directory not writable: $SSH_KEYS_DIR" >&2
        exit 1
    fi

    # check for ssh-keygen
    if ! command -v ssh-keygen >/dev/null 2>&1; then
        echo "ERROR: ssh-keygen not found in PATH" >&2
        exit 1
    fi

    LOGFILE="${SSH_KEYS_DIR}/regen.log"
    echo "Regeneration started at $(date)" > "$LOGFILE"

    # Generate keys (allow individual failures so other types still attempt)
    ssh-keygen -t dsa -f "${SSH_KEYS_DIR}/ssh_host_dsa_key" -N "" &>> "$LOGFILE" || echo "dsa keygen failed" >> "$LOGFILE"
    ssh-keygen -t rsa -f "${SSH_KEYS_DIR}/ssh_host_rsa_key" -N "" &>> "$LOGFILE" || echo "rsa keygen failed" >> "$LOGFILE"
    ssh-keygen -t ecdsa -f "${SSH_KEYS_DIR}/ssh_host_ecdsa_key" -N "" &>> "$LOGFILE" || echo "ecdsa keygen failed" >> "$LOGFILE"
    ssh-keygen -t ed25519 -f "${SSH_KEYS_DIR}/ssh_host_ed25519_key" -N "" &>> "$LOGFILE" || echo "ed25519 keygen failed" >> "$LOGFILE"

    echo "Regeneration finished at $(date)" >> "$LOGFILE"
    echo "==> Generated files (in $SSH_KEYS_DIR):"
    ls -la "$SSH_KEYS_DIR" || true
    echo "(keygen log: $LOGFILE)"
fi
rm -f /etc/ssh/ssh_host_*
cp -rp "${SSH_KEYS_DIR}"/. /etc/ssh/

echo '==> SSH host keys regenerated and copied to /etc/ssh/'
