#!/bin/sh
# cleanup.sh - Safe cleanup of apt, snap, caches and old kernels on Ubuntu
# Usage: sudo ./cleanup.sh [-n|--dry-run] [-y|--yes]
set -eu

DRY_RUN=0
ASSUME_YES=0

print_help() {
    cat <<'EOF'
Usage: cleanup.sh [-n|--dry-run] [-y|--yes]

-n, --dry-run   Show actions without executing them
-y, --yes       Run non-interactively (answer yes to prompts)
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--dry-run) DRY_RUN=1; shift ;;
        -y|--yes) ASSUME_YES=1; shift ;;
        -h|--help) print_help; exit 0 ;;
        *) echo "Unknown arg: $1"; print_help; exit 2 ;;
    esac
done

run() {
    if [ $DRY_RUN -eq 1 ]; then
        echo "[DRY-RUN] $*"
    else
        echo "+ $*"
        eval "$@"
    fi
}

confirm() {
    if [ $ASSUME_YES -eq 1 ]; then
        return 0
    fi
    printf '%s [y/N]: ' "$1"
    read resp
    case "$resp" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# require root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script needs root. Re-run with sudo."
    exit 1
fi

echo "Starting cleanup (dry-run=$DRY_RUN)."

# 1) apt: autoremove, autoclean, clean
if confirm "Run apt autoremove and clean?"; then
    run "apt-get update -qq"
    run "apt-get -y --allow-remove-essential --allow-change-held-packages autoremove --purge"
    run "apt-get -y autoclean"
    run "apt-get -y clean"
fi

# 2) purge residual config packages (status rc)
if confirm "Purge residual config files for removed packages?"; then
    # list packages with rc status and purge them
    RC_PKGS=$(dpkg -l | awk '/^rc/{print $2}' || true)
    if [ -n "$RC_PKGS" ]; then
        run "dpkg --purge $RC_PKGS"
    else
        echo "No residual config packages found."
    fi
fi

# 3) list old kernels and optionally remove (keep current)
CURRENT_KERNEL="$(uname -r)"
echo "Current kernel: $CURRENT_KERNEL"
OLD_KERNELS=$(dpkg --list 'linux-image-*' 2>/dev/null | awk '/^ii/{print $2}' | grep -v -- "$CURRENT_KERNEL" || true)
if [ -n "$OLD_KERNELS" ]; then
    echo "Old kernel packages detected:"
    echo "$OLD_KERNELS"
    if confirm "Purge the listed old kernel packages?"; then
        run "apt-get -y purge $OLD_KERNELS"
        run "update-grub || true"
    fi
else
    echo "No old linux-image packages found (besides current)."
fi

# 4) clean snap old revisions
if command -v snap >/dev/null 2>&1; then
    SNAP_COUNT=$(snap list --all 2>/dev/null | awk '/disabled/{count++} END {print count+0}')
    if [ "$SNAP_COUNT" -gt 0 ]; then
        echo "Old snap revisions found:"
        snap list --all 2>/dev/null | awk '/disabled/{print "  " $1 ":" $3}'
        if confirm "Remove disabled snap revisions?"; then
            snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' | while read name rev; do
                run "snap remove \"$name\" --revision=\"$rev\" || true"
            done
        fi
    else
        echo "No disabled snap revisions found."
    fi
fi

# 5) vacuum systemd journal logs older than 2 weeks
if command -v journalctl >/dev/null 2>&1; then
    if confirm "Vacuum journal logs older than 2 weeks?"; then
        run "journalctl --vacuum-time=2weeks || true"
    fi
fi

# 6) clear apt lists
if confirm "Remove /var/lib/apt/lists to free apt list cache?"; then
    run "rm -rf /var/lib/apt/lists/*"
fi

# 7) clear thumbnail cache for all users (safe for cache only)
if confirm "Clear thumbnail caches in /home/*/.cache/thumbnails and root?"; then
    for d in /home/*/.cache/thumbnails /root/.cache/thumbnails; do
        if [ -d "$d" ]; then
            run "rm -rf \"$d\"/*"
        fi
    done
fi

# 8) remove files in /tmp older than 7 days
if confirm "Remove files in /tmp older than 7 days?"; then
    run "find /tmp -mindepth 1 -mtime +7 -exec rm -rf {} + || true"
fi

echo "Cleanup finished."