#!/bin/bash
# Helper script to replace Discord RPC native library with arm64 version
# Usage: ./fix-apple-silicon.sh /path/to/arm64/libdiscord-rpc.dylib

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/arm64/libdiscord-rpc.dylib"
    echo ""
    echo "This script replaces the x86_64 Discord RPC library with an arm64 version."
    echo ""
    echo "First, build the arm64 library:"
    echo "  1. git clone https://github.com/discord/discord-rpc.git"
    echo "  2. cd discord-rpc"
    echo "  3. mkdir build && cd build"
    echo "  4. cmake .. -DCMAKE_OSX_ARCHITECTURES=arm64"
    echo "  5. cmake --build . --config Release"
    echo "  6. Then run this script: $0 build/src/libdiscord-rpc.dylib"
    exit 1
fi

NEW_LIB="$1"
JAR_FILE="libs/java-discord-rpc-2.0.1-all.jar"

if [ ! -f "$NEW_LIB" ]; then
    echo "Error: Library file not found: $NEW_LIB"
    exit 1
fi

if [ ! -f "$JAR_FILE" ]; then
    echo "Error: JAR file not found: $JAR_FILE"
    exit 1
fi

# Verify the new library is arm64
echo "Verifying library architecture..."
if command -v file &> /dev/null; then
    ARCH=$(file "$NEW_LIB" | grep -o "arm64\|x86_64" || echo "")
    if [[ "$ARCH" != "arm64" ]]; then
        echo "Warning: Library may not be arm64. File info:"
        file "$NEW_LIB"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo "✓ Library is arm64"
    fi
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Extracting JAR..."
cd "$TEMP_DIR"
unzip -q "$OLDPWD/$JAR_FILE"

echo "Replacing darwin/libdiscord-rpc.dylib..."
cp "$OLDPWD/$NEW_LIB" darwin/libdiscord-rpc.dylib

echo "Rebuilding JAR..."
zip -q -r "$OLDPWD/$JAR_FILE" .

echo "✓ Successfully replaced library in $JAR_FILE"
echo ""
echo "Now rebuild the extension:"
echo "  ./gradlew clean build"

