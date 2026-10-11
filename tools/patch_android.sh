#!/usr/bin/env bash
# Wire Asan Bill Viewer specifics into the flutter-generated android/ folder.
# Idempotent. Run from the project root after `flutter create --platforms=android .`
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/patch_android.py
