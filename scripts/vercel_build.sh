#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.44.4"

if ! command -v flutter >/dev/null 2>&1 || ! flutter --version | grep -q "^Flutter ${FLUTTER_VERSION} "; then
  FLUTTER_ROOT="$HOME/.cache/flutter/${FLUTTER_VERSION}"
  if [ ! -x "$FLUTTER_ROOT/bin/flutter" ]; then
    mkdir -p "$(dirname "$FLUTTER_ROOT")"
    git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
  fi
  export PATH="$FLUTTER_ROOT/bin:$PATH"
fi

flutter --version
flutter pub get
flutter build web --release
