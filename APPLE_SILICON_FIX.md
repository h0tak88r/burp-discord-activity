# Fixing Apple Silicon (arm64) Compatibility

## Problem

The `java-discord-rpc-2.0.1-all.jar` library includes native libraries that are **x86_64 only**:
- `darwin/libdiscord-rpc.dylib` - x86_64 architecture only
- Old JNA (Java Native Access) library without arm64 support

This causes `UnsatisfiedLinkError` when running on Apple Silicon Macs.

## Solution: Build arm64 Discord RPC Native Library

You need to build the Discord RPC native library for arm64 and replace it in the JAR file.

### Step 1: Build Discord RPC Native Library for arm64

1. **Install build dependencies on your Mac:**
   ```bash
   brew install cmake
   ```

2. **Clone the Discord RPC repository:**
   ```bash
   git clone https://github.com/discord/discord-rpc.git
   cd discord-rpc
   ```

3. **Build for arm64:**
   ```bash
   mkdir build && cd build
   cmake .. -DCMAKE_OSX_ARCHITECTURES=arm64
   cmake --build . --config Release
   ```

4. **Find the built library:**
   The library will be at: `build/src/libdiscord-rpc.dylib`

5. **Verify it's arm64:**
   ```bash
   file build/src/libdiscord-rpc.dylib
   # Should show: Mach-O 64-bit dynamically linked shared library arm64
   ```

### Step 2: Replace the Library in the JAR

**Option A: Using the Helper Script (Easiest)**

```bash
cd /path/to/burp-discord-activity
./fix-apple-silicon.sh /path/to/discord-rpc/build/src/libdiscord-rpc.dylib
./gradlew clean build
```

**Option B: Manual Replacement**

1. **Extract the JAR:**
   ```bash
   cd /path/to/burp-discord-activity
   mkdir -p temp_jar
   cd temp_jar
   unzip ../libs/java-discord-rpc-2.0.1-all.jar
   ```

2. **Replace the dylib:**
   ```bash
   cp /path/to/discord-rpc/build/src/libdiscord-rpc.dylib darwin/libdiscord-rpc.dylib
   ```

3. **Rebuild the JAR:**
   ```bash
   zip -r ../libs/java-discord-rpc-2.0.1-all.jar .
   cd ..
   rm -rf temp_jar
   ```

4. **Rebuild the extension:**
   ```bash
   ./gradlew clean build
   ```

### Alternative: Use Pre-built arm64 Library (if available)

If someone has already built an arm64 version, you can:

1. Download the arm64 `libdiscord-rpc.dylib` file
2. Follow Step 2 above to replace it in the JAR

## Verification

After rebuilding, the extension should work on Apple Silicon. Check Burp Suite's **Errors** tab - you should see:
- "Burp Discord Activity loaded" in the Output tab
- No `UnsatisfiedLinkError` in the Errors tab

## Note on JNA

The build.gradle has been updated to include JNA 5.13.0, which has arm64 support. This will override the old JNA included in the Discord RPC library. However, you still need to replace the Discord RPC native library itself as described above.

