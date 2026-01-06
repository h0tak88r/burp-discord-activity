#!/bin/bash
# Use a pre-built universal binary (if available)
# This avoids needing cmake!

set -e

UNIVERSAL_LIB="$1"

if [ -z "$UNIVERSAL_LIB" ]; then
    echo "Usage: $0 /path/to/libdiscord-rpc-universal.dylib"
    echo ""
    echo "If someone has already built a universal binary, you can use it here"
    echo "and avoid installing cmake!"
    echo ""
    echo "The universal binary should be a fat binary with both x86_64 and arm64."
    exit 1
fi

if [ ! -f "$UNIVERSAL_LIB" ]; then
    echo "Error: Library file not found: $UNIVERSAL_LIB"
    exit 1
fi

# Verify it's universal
echo "Verifying universal binary..."
if command -v lipo &> /dev/null; then
    ARCHS=$(lipo -info "$UNIVERSAL_LIB" 2>&1)
    if echo "$ARCHS" | grep -q "x86_64" && echo "$ARCHS" | grep -q "arm64"; then
        echo "✓ Universal binary confirmed (x86_64 + arm64)"
    else
        echo "⚠ Warning: May not be a universal binary"
        echo "Architectures: $ARCHS"
    fi
else
    echo "⚠ Cannot verify (lipo not available), proceeding anyway..."
fi

# Replace in JAR
echo ""
echo "Replacing library in JAR..."
./fix-apple-silicon.sh "$UNIVERSAL_LIB"

# Rebuild extension
echo ""
echo "Rebuilding extension..."
./gradlew clean build

echo ""
echo "✓ Done! Your extension is at: build/libs/BurpDiscordActivity-1.0.0.jar"

