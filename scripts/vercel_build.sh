#!/usr/bin/env bash
set -euo pipefail

if command -v flutter >/dev/null 2>&1; then
  flutter pub get
else
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$PWD/.flutter"
  export PATH="$PWD/.flutter/bin:$PATH"
  flutter pub get
fi

flutter build web --release
