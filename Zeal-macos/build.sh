#!/bin/bash
set -e
set -o pipefail

cd "$(dirname "$0")"

GIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "dev")

echo "Building Zeal..."
echo "Git SHA: ${GIT_SHA:0:7}"

xcodebuild \
  -scheme Zeal \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath ./build \
  "GIT_COMMIT_SHA=$GIT_SHA" \
  clean build \
  | grep -E "(^Compile|^Link|^Sign|^Touch|error:|warning:|\*\* BUILD)" \
  | sed -E 's/.*\((in target.*)\)/\1/'

echo ""
echo "Done! App located at:"
echo "  ./build/Build/Products/Release/Zeal.app"
