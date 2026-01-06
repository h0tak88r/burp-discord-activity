#!/bin/bash
# Run this script on your Mac to complete the Apple Silicon build
# This script will guide you through building the arm64 Discord RPC library

set -e

echo "=========================================="
echo "Building Burp Discord Activity for Apple Silicon"
echo "=========================================="
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script must be run on macOS"
    exit 1
fi

# Check for required tools
echo "Checking requirements..."
echo ""

# Check for Java
if ! command -v java &> /dev/null; then
    echo "⚠ Warning: Java not found in PATH"
    echo "   Burp Suite should include Java, but if you get errors, install Java 17+"
    echo ""
else
    echo "✓ Java found: $(java -version 2>&1 | head -1)"
fi

# Check for Git
if ! command -v git &> /dev/null; then
    echo "Error: Git not found. Please install Git:"
    echo "  xcode-select --install"
    echo "  OR: brew install git"
    exit 1
else
    echo "✓ Git found"
fi

# Check for cmake (only needed if building from source)
CMAKE_NEEDED=false
if [ ! -f "../discord-rpc/libdiscord-rpc-universal.dylib" ] && [ ! -f "libdiscord-rpc-universal.dylib" ]; then
    CMAKE_NEEDED=true
    if ! command -v cmake &> /dev/null; then
        echo "⚠ cmake not found. You have two options:"
        echo ""
        echo "Option 1: Install cmake and build (one time):"
        echo "  brew install cmake"
        echo "  Then run this script again"
        echo ""
        echo "Option 2: Use a pre-built universal binary (no cmake needed!):"
        echo "  ./use-prebuilt-universal.sh /path/to/libdiscord-rpc-universal.dylib"
        echo ""
        read -p "Install cmake now? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if command -v brew &> /dev/null; then
                brew install cmake
            else
                echo "Error: Homebrew not found. Please install cmake manually:"
                echo "  brew install cmake"
                exit 1
            fi
        else
            echo "Exiting. Install cmake or use a pre-built universal binary."
            exit 1
        fi
    else
        echo "✓ cmake found"
    fi
else
    echo "✓ Found existing universal binary - cmake not needed!"
fi

echo ""
echo "Note: Gradle wrapper (gradlew) is included - no Gradle installation needed!"
if [ "$CMAKE_NEEDED" = true ]; then
    echo "Note: This will build a universal binary (works on Intel + Apple Silicon)"
fi
echo ""

# Check if Discord RPC is already built
DISCORD_RPC_PATH=""
if [ -f "../discord-rpc/build/src/libdiscord-rpc.dylib" ]; then
    DISCORD_RPC_PATH="../discord-rpc/build/src/libdiscord-rpc.dylib"
    echo "Found existing Discord RPC library at: $DISCORD_RPC_PATH"
    read -p "Use this library? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        DISCORD_RPC_PATH=""
    fi
fi

# Check for universal binary first
if [ -f "../discord-rpc/libdiscord-rpc-universal.dylib" ]; then
    DISCORD_RPC_PATH="../discord-rpc/libdiscord-rpc-universal.dylib"
    echo "Found universal binary - will work on both Intel and Apple Silicon!"
elif [ -f "libdiscord-rpc-universal.dylib" ]; then
    DISCORD_RPC_PATH="libdiscord-rpc-universal.dylib"
    echo "Found universal binary - will work on both Intel and Apple Silicon!"
fi

# Build Discord RPC if needed
if [ -z "$DISCORD_RPC_PATH" ]; then
    echo ""
    echo "Building universal Discord RPC library (x86_64 + arm64)..."
    echo "This will work on both Intel and Apple Silicon Macs!"
    echo ""
    
    if [ ! -d "../discord-rpc" ]; then
        echo "Cloning Discord RPC repository..."
        cd ..
        git clone https://github.com/discord/discord-rpc.git
        cd discord-rpc
    else
        echo "Using existing discord-rpc directory..."
        cd ../discord-rpc
    fi
    
    # Fix CMakeLists.txt if needed (for newer cmake versions)
    if [ -f "CMakeLists.txt" ]; then
        if grep -q "cmake_minimum_required(VERSION 2.8)" CMakeLists.txt 2>/dev/null || \
           grep -q "cmake_minimum_required(VERSION 3.0)" CMakeLists.txt 2>/dev/null || \
           grep -q "cmake_minimum_required(VERSION 3.1)" CMakeLists.txt 2>/dev/null; then
            echo "Fixing CMakeLists.txt for newer cmake (4.x)..."
            # Create backup
            cp CMakeLists.txt CMakeLists.txt.bak 2>/dev/null || true
            # Update minimum version to 3.5
            sed -i.bak 's/cmake_minimum_required(VERSION [0-9.]*)/cmake_minimum_required(VERSION 3.5)/' CMakeLists.txt
            echo "✓ Updated CMakeLists.txt"
        fi
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
    
    # Create universal binary
    echo "Creating universal binary (combining both architectures)..."
    UNIVERSAL_LIB="$(pwd)/libdiscord-rpc-universal.dylib"
    lipo -create "$X86_LIB" "$ARM64_LIB" -output "$UNIVERSAL_LIB"
    
    DISCORD_RPC_PATH="$UNIVERSAL_LIB"
    cd ..
    
    # Verify
    echo ""
    echo "Verifying universal binary..."
    lipo -info "$DISCORD_RPC_PATH"
    echo "✓ Universal binary created (works on Intel + Apple Silicon)"
fi

# Replace library in JAR
echo ""
echo "Replacing library in JAR..."
./fix-apple-silicon.sh "$DISCORD_RPC_PATH"

# Rebuild extension
echo ""
echo "Rebuilding extension..."
./gradlew clean build

echo ""
echo "=========================================="
echo "✓ Build complete!"
echo "=========================================="
echo ""
echo "Your Apple Silicon-compatible extension is at:"
echo "  build/libs/BurpDiscordActivity-1.0.0.jar"
echo ""
echo "Load this JAR into Burp Suite on your Mac!"

