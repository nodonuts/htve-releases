#!/usr/bin/env bash
# HTVE Platform public bootstrap — pinned upstream-only release candidate.
set -euo pipefail
umask 077

REPO="nodonuts/htve-releases"
RELEASE_TAG="v0.2.0-rc3"
ARCHIVE="htve-platform-upstream-v0.2.0-rc3.tar.gz"
SHA256="eff218a332464212e6853c29641cb74b4db9a8a088e06adfe9e8a9191e60c35a"
BASE="https://github.com/${REPO}/releases/download/${RELEASE_TAG}"
INSTALL_DIR="/opt/htve-platform-installers/${RELEASE_TAG}"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<EOF
HTVE Platform upstream-only bootstrap (${RELEASE_TAG})

Usage:
  bash htve-install.sh --verify           Download and verify only (safe on existing hosts)
  bash htve-install.sh --install     Install on clean Debian 13 amd64
  bash htve-install.sh --resume ID   Resume an interrupted installation

With no arguments, --install is assumed.
Release files remain at ${INSTALL_DIR} for recovery.
This is a pre-release; do not use for critical production deployments.
EOF
}

ACTION="${1:---install}"
case "$ACTION" in
    --help|-h)
        [[ $# -eq 1 ]] || die "Unexpected arguments"
        usage
        exit 0
        ;;
    --verify|--install)
        [[ $# -le 1 ]] || die "Unexpected arguments"
        ;;
    --resume)
        [[ $# -eq 2 ]] || die "Usage: --resume SITE_ID"
        [[ "$2" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]] || die "Invalid SITE_ID"
        ;;
    *)
        usage >&2
        die "Unrecognized argument: $ACTION"
        ;;
esac

if [[ "$ACTION" == "--resume" ]]; then
    [[ "$(id -u)" -eq 0 ]] || die "Resume requires root"
    [[ -f "${INSTALL_DIR}/htve-platform/install.sh" ]] ||
        die "No existing installer found at ${INSTALL_DIR}"
    cd "${INSTALL_DIR}/htve-platform"
    exec ./install.sh --resume "$2"
fi

for command in curl tar sha256sum cmp mktemp; do
    command -v "$command" >/dev/null 2>&1 || die "Missing required command: $command"
done

if [[ "$ACTION" == "--install" ]]; then
    [[ "$(id -u)" -eq 0 ]] || die "Installation requires a root shell"
    [[ -r /etc/os-release ]] || die "Cannot check operating system"
    # shellcheck source=/dev/null
    source /etc/os-release
    [[ "${ID:-}" == "debian" && "${VERSION_ID:-}" == "13" ]] ||
        die "Installation requires Debian 13"
    [[ "$(dpkg --print-architecture)" == "amd64" ]] ||
        die "Installation requires amd64"
    [[ ! -e "$INSTALL_DIR" && ! -L "$INSTALL_DIR" ]] ||
        die "Installer directory already exists: $INSTALL_DIR (use --resume if interrupted)"
fi

TMPDIR_HTVE="$(mktemp -d /tmp/htve-bootstrap-XXXXXXXX)"
trap 'rm -rf "$TMPDIR_HTVE"' EXIT

printf 'HTVE Platform %s: downloading release archive and checksum...\n' "$RELEASE_TAG"
curl --proto '=https' --tlsv1.2 -fsSL --retry 3 --connect-timeout 15 \
    -o "$TMPDIR_HTVE/$ARCHIVE" "$BASE/$ARCHIVE"
curl --proto '=https' --tlsv1.2 -fsSL --retry 3 --connect-timeout 15 \
    -o "$TMPDIR_HTVE/SHA256SUMS.txt" "$BASE/SHA256SUMS.txt"

printf '%s  %s\n' "$SHA256" "$ARCHIVE" |
    cmp - "$TMPDIR_HTVE/SHA256SUMS.txt" ||
    die "Published checksum file differs from the pinned release checksum"

(
    cd "$TMPDIR_HTVE"
    sha256sum -c SHA256SUMS.txt
) || die "Archive checksum verification failed"

tar -tzf "$TMPDIR_HTVE/$ARCHIVE" >/dev/null ||
    die "Archive integrity verification failed"

printf 'Release %s verified (pinned SHA-256).\n' "$RELEASE_TAG"
if [[ "$ACTION" == "--verify" ]]; then
    echo "Verification only: no HTVE configuration or containers changed."
    exit 0
fi

install -d -m 700 "$(dirname "$INSTALL_DIR")"
mkdir -m 700 "$INSTALL_DIR"
tar -xzf "$TMPDIR_HTVE/$ARCHIVE" -C "$INSTALL_DIR"
[[ -f "$INSTALL_DIR/htve-platform/install.sh" ]] ||
    die "Expected installer missing from archive"

printf 'Installer preserved at: %s\n' "$INSTALL_DIR"
echo "Starting the interactive HTVE installer..."
cd "$INSTALL_DIR/htve-platform"
./install.sh --install
