#!/bin/bash
set -e

cd "$(dirname "$0")"

GIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "dev")

echo "Building Zeal..."
echo "Git SHA: ${GIT_SHA:0:7}"

xcodebuild \
  -scheme Zeal \
  -configuration Release \
  -derivedDataPath ./build \
  "GIT_COMMIT_SHA=$GIT_SHA" \
  build \
  | grep -E "^(Build|Compile|Link|Sign|Touch|\*\*)" || true

echo ""
echo "Done! App located at:"
echo "  ./build/Build/Products/Release/Zeal.app"
