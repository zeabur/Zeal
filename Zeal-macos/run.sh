#!/bin/bash
cd "$(dirname "$0")"

# 1. Close existing instance
./close.sh

# 2. Build and Open if successful
./build.sh && ./open.sh
