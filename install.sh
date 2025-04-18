#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ────────────────────────────────────────────────────────────────
readonly REPO="AdityaMotale/raven"
readonly BINARY_NAME="raven"
readonly DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}-linux-amd64"

usage() {
  cat <<EOF
Usage: install.sh [DEST_DIR]

By default, if run as root, installs to /usr/local/bin;
otherwise installs to \$HOME/.local/bin.

You can override DEST_DIR by:
  • Passing it as the first argument:
      curl … | bash -s -- /custom/path
  • Or exporting:
      DEST_DIR=/custom/path curl … | bash
EOF
  exit 1
}

# ─── PARSE ARGS & ENV OVERRIDE ──────────────────────────────────────────────
# 1) If user passed a positional arg, use that.
# 2) Else if DEST_DIR is already set in env, use that.
# 3) Else auto‑detect based on EUID.
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

if [[ -n "${1:-}" ]]; then
  DEST_DIR="$1"
elif [[ -n "${DEST_DIR:-}" ]]; then
  # exported by user
  DEST_DIR="$DEST_DIR"
elif [[ "$EUID" -eq 0 ]]; then
  DEST_DIR="/usr/local/bin"
else
  DEST_DIR="$HOME/.local/bin"
fi

# ─── PRECHECKS ─────────────────────────────────────────────────────────────
if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
  echo "Error: curl or wget is required to download the binary." >&2
  exit 1
fi

# make sure the destination exists
if [ ! -d "$DEST_DIR" ]; then
  echo "Creating destination directory $DEST_DIR"
  mkdir -p "$DEST_DIR"
fi

# ─── DOWNLOAD & INSTALL ────────────────────────────────────────────────────
echo "Downloading ${BINARY_NAME} from GitHub Releases…"
if command -v curl &>/dev/null; then
  curl -sSL "$DOWNLOAD_URL" -o "${DEST_DIR}/${BINARY_NAME}"
else
  wget -qO "${DEST_DIR}/${BINARY_NAME}" "$DOWNLOAD_URL"
fi

chmod +x "${DEST_DIR}/${BINARY_NAME}"
echo "✔ Installed to ${DEST_DIR}/${BINARY_NAME}"
echo
echo "Try it:"
echo "  $ ${BINARY_NAME} d2b 42      # decimal -> binary"
