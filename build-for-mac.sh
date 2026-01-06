#!/bin/bash
# Script to prepare the project for building on Mac Apple Silicon
# This builds the JAR with x86_64 libraries, which you'll then fix on Mac

set -e

echo "Building extension JAR (with x86_64 libraries)..."
echo "Note: You'll need to replace the Discord RPC library on your Mac for arm64 support"
echo ""

./gradlew clean build

echo ""
echo "✓ Build complete!"
echo ""
echo "The JAR is at: build/libs/BurpDiscordActivity-1.0.0.jar"
echo ""
echo "Next steps on your Mac:"
echo "1. Transfer the JAR to your Mac"
echo "2. Build the arm64 Discord RPC library (see APPLE_SILICON_FIX.md)"
echo "3. Run: ./fix-apple-silicon.sh /path/to/arm64/libdiscord-rpc.dylib"
echo "4. Rebuild: ./gradlew clean build"
echo "5. Load the new JAR into Burp Suite"

