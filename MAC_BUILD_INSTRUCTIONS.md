# Building for Mac Apple Silicon from Linux/Windows

## Overview

You can build the extension JAR on any platform, but the **Discord RPC native library must be built on macOS** because it requires macOS-specific tools and SDKs.

## Step 1: Build the Extension (On Any Platform)

Build the extension on your current system (Linux/Windows):

```bash
./gradlew clean build
```

Or use the helper script:
```bash
./build-for-mac.sh
```

This creates: `build/libs/BurpDiscordActivity-1.0.0.jar`

**Note:** This JAR will have x86_64 Discord RPC libraries and won't work on Apple Silicon yet.

## Step 2: Transfer to Your Mac

Copy the following to your Mac:
- The entire project directory (or at minimum):
  - `build/libs/BurpDiscordActivity-1.0.0.jar` (the built extension)
  - `libs/java-discord-rpc-2.0.1-all.jar` (the Discord RPC library)
  - `fix-apple-silicon.sh` (the helper script)
  - `build.gradle` and other build files
  - `gradlew` (Gradle wrapper)

## Step 3: Build arm64 Discord RPC Library (On Your Mac)

On your Mac, build the Discord RPC native library for arm64:

```bash
# Install build tools
brew install cmake

# Clone and build Discord RPC
git clone https://github.com/discord/discord-rpc.git
cd discord-rpc
mkdir build && cd build
cmake .. -DCMAKE_OSX_ARCHITECTURES=arm64
cmake --build . --config Release

# Verify it's arm64
file src/libdiscord-rpc.dylib
# Should show: Mach-O 64-bit dynamically linked shared library arm64
```

The built library will be at: `discord-rpc/build/src/libdiscord-rpc.dylib`

## Step 4: Replace Library in JAR (On Your Mac)

Navigate to your project directory on Mac and run:

```bash
./fix-apple-silicon.sh /path/to/discord-rpc/build/src/libdiscord-rpc.dylib
```

This script will:
1. Extract the JAR
2. Replace the x86_64 library with your arm64 version
3. Rebuild the JAR

## Step 5: Rebuild Extension (On Your Mac)

Rebuild the extension to create a fresh JAR:

```bash
./gradlew clean build
```

The new JAR at `build/libs/BurpDiscordActivity-1.0.0.jar` will now work on Apple Silicon!

## Step 6: Load in Burp Suite

1. Open Burp Suite on your Mac
2. Go to **Extensions** tab
3. Click **Add**
4. Select **Java** as extension type
5. Choose `build/libs/BurpDiscordActivity-1.0.0.jar`
6. The extension should load without errors!

## Alternative: Quick Test Without Rebuilding

If you just want to test quickly, you can:

1. Build the extension on your current system
2. Transfer just the JAR to your Mac
3. On Mac, extract and replace the library manually:
   ```bash
   mkdir temp_jar && cd temp_jar
   unzip ../build/libs/BurpDiscordActivity-1.0.0.jar
   cp /path/to/arm64/libdiscord-rpc.dylib darwin/libdiscord-rpc.dylib
   zip -r ../BurpDiscordActivity-1.0.0-fixed.jar .
   cd .. && rm -rf temp_jar
   ```
4. Load `BurpDiscordActivity-1.0.0-fixed.jar` into Burp Suite

## Troubleshooting

- **"Permission denied" on scripts**: Run `chmod +x fix-apple-silicon.sh gradlew`
- **JNA errors**: The build.gradle already includes JNA 5.13.0 with arm64 support
- **Still getting UnsatisfiedLinkError**: Make sure you replaced the library correctly and rebuilt

