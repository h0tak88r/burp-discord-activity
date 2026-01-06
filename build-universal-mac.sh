#!/bin/bash
# Build a universal (fat) binary that works on both Intel and Apple Silicon Macs
# This creates a single JAR that works everywhere - no cmake needed for end users!

set -e

echo "=========================================="
echo "Building Universal Mac Binary (x86_64 + arm64)"
echo "=========================================="
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script must be run on macOS"
    exit 1
fi

# Check for required tools
if ! command -v cmake &> /dev/null; then
    echo "Installing cmake..."
    if command -v brew &> /dev/null; then
        brew install cmake
    else
        echo "Error: Homebrew not found. Please install cmake:"
        echo "  brew install cmake"
        exit 1
    fi
fi

if ! command -v git &> /dev/null; then
    echo "Error: Git not found. Install with: xcode-select --install"
    exit 1
fi

echo "Building universal binary (this will take a few minutes)..."
echo ""

# Clone Discord RPC if needed
if [ ! -d "discord-rpc" ]; then
    echo "Cloning Discord RPC repository..."
    git clone https://github.com/discord/discord-rpc.git
fi

cd discord-rpc

# Fix CMakeLists.txt if needed (for newer cmake versions)
if grep -q "cmake_minimum_required(VERSION 2.8)" CMakeLists.txt 2>/dev/null; then
    echo "Fixing CMakeLists.txt for newer cmake..."
    sed -i.bak 's/cmake_minimum_required(VERSION 2.8)/cmake_minimum_required(VERSION 3.5)/' CMakeLists.txt
fi

# Build for x86_64
echo "Building x86_64 version..."
rm -rf build-x86_64
mkdir -p build-x86_64
cd build-x86_64
cmake .. -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build . --config Release
X86_LIB="$(pwd)/src/libdiscord-rpc.dylib"
cd ..

# Build for arm64
echo "Building arm64 version..."
rm -rf build-arm64
mkdir -p build-arm64
cd build-arm64
cmake .. -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build . --config Release
ARM64_LIB="$(pwd)/src/libdiscord-rpc.dylib"
cd ..

# Create universal (fat) binary using lipo
echo "Creating universal binary (combining both architectures)..."
UNIVERSAL_LIB="$(pwd)/libdiscord-rpc-universal.dylib"
lipo -create "$X86_LIB" "$ARM64_LIB" -output "$UNIVERSAL_LIB"

# Verify
echo ""
echo "Verifying universal binary..."
file "$UNIVERSAL_LIB"
lipo -info "$UNIVERSAL_LIB"
echo ""

cd ..

# Replace in JAR
echo "Replacing library in JAR with universal binary..."
./fix-apple-silicon.sh "$UNIVERSAL_LIB"

# Rebuild extension
echo ""
echo "Rebuilding extension..."
./gradlew clean build

echo ""
echo "=========================================="
echo "✓ Universal build complete!"
echo "=========================================="
echo ""
echo "Your universal extension (works on Intel AND Apple Silicon) is at:"
echo "  build/libs/BurpDiscordActivity-1.0.0.jar"
echo ""
echo "This JAR will work on:"
echo "  ✓ Intel Macs (x86_64)"
echo "  ✓ Apple Silicon Macs (arm64)"
echo ""
echo "No cmake needed for end users - just load this JAR into Burp Suite!"

