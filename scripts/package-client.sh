#!/usr/bin/env bash
# Builds a native installer of the JavaFX client with jpackage for the CURRENT OS
# (Linux: .deb, Windows: .msi, macOS: .dmg). Used by .github/workflows/release.yml.
#
#   scripts/package-client.sh [version]      # version defaults to 1.0.0
#
# jpackage requires: Linux -> dpkg/fakeroot, Windows -> WiX Toolset, macOS -> Xcode tools.
set -euo pipefail

VERSION="${1:-1.0.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

./mvnw -B -q -pl bookstore-client -am package -DskipTests

case "$(uname -s)" in
  Linux*)               TYPE=deb ;;
  Darwin*)              TYPE=dmg ;;
  MINGW*|MSYS*|CYGWIN*) TYPE=msi ;;
  *) echo "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

INPUT=bookstore-client/target/libs
cp bookstore-client/target/bookstore-client.jar "$INPUT/"
mkdir -p dist

jpackage \
  --type "$TYPE" \
  --name OnlineBookstore \
  --app-version "$VERSION" \
  --vendor "Online Bookstore Team" \
  --input "$INPUT" \
  --main-jar bookstore-client.jar \
  --main-class com.bookstore.client.Launcher \
  --dest dist

echo "Installer written to dist/"
