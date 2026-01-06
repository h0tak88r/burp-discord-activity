#!/bin/bash
# Prepare everything needed to build on Mac Apple Silicon
# Run this on Linux/Windows, then complete the build on Mac

set -e

echo "=========================================="
echo "Preparing project for Mac Apple Silicon"
echo "=========================================="
echo ""

# Build the extension
echo "Building extension JAR..."
./gradlew clean build --no-daemon

echo ""
echo "✓ Build complete!"
echo ""

# Create a package with everything needed
PACKAGE_DIR="mac-build-package"
mkdir -p "$PACKAGE_DIR"

echo "Creating package for Mac..."
cp build/libs/BurpDiscordActivity-1.0.0.jar "$PACKAGE_DIR/"
cp libs/java-discord-rpc-2.0.1-all.jar "$PACKAGE_DIR/"
cp fix-apple-silicon.sh "$PACKAGE_DIR/"
cp build.gradle "$PACKAGE_DIR/"
cp settings.gradle "$PACKAGE_DIR/"
cp -r gradle "$PACKAGE_DIR/"
cp gradlew "$PACKAGE_DIR/"
cp gradlew.bat "$PACKAGE_DIR/" 2>/dev/null || true
cp APPLE_SILICON_FIX.md "$PACKAGE_DIR/"
cp MAC_BUILD_INSTRUCTIONS.md "$PACKAGE_DIR/"

# Create a README for the package
cat > "$PACKAGE_DIR/README.txt" << 'EOF'
==========================================
Mac Apple Silicon Build Package
==========================================

This package contains everything you need to build the extension for Mac Apple Silicon.

QUICK START:
1. Transfer this entire folder to your Mac
2. Open Terminal on Mac and navigate to this folder
3. Run: ./build-on-mac.sh
   (This will guide you through building the arm64 library)

WHAT'S INCLUDED:
- BurpDiscordActivity-1.0.0.jar (built extension, needs arm64 fix)
- java-discord-rpc-2.0.1-all.jar (Discord RPC library)
- fix-apple-silicon.sh (helper script to replace library)
- build.gradle, gradlew (build files)
- Documentation files

See MAC_BUILD_INSTRUCTIONS.md for detailed steps.
EOF

echo "✓ Package created in: $PACKAGE_DIR/"
echo ""
echo "Next steps:"
echo "1. Transfer the '$PACKAGE_DIR' folder to your Mac"
echo "2. On Mac, run: ./build-on-mac.sh"
echo "   (or follow MAC_BUILD_INSTRUCTIONS.md)"
echo ""
echo "The package is ready to transfer!"

