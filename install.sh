#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ────────────────────────────────────────────────────────────────
REPO="AdityaMotale/raven"
BINARY_NAME="raven"
DEST_DIR="${DEST_DIR:-/usr/local/bin}"

DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}-linux-amd64"

# ─── PRECHECKS ─────────────────────────────────────────────────────────────
if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
  echo "Error: curl or wget is required to download the binary." >&2
  exit 1
fi

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
echo "Installed to ${DEST_DIR}/${BINARY_NAME}"
echo
echo "Try it: ${BINARY_NAME} d2b 42      # decimal -> binary"
echo
