# Universal Mac Build (No cmake needed for end users!)

## The Problem

Building for Apple Silicon requires cmake, which is a large installation. But we can solve this by creating a **universal binary** that works on both Intel and Apple Silicon Macs!

## Solution: Universal Binary

A universal (fat) binary contains **both** x86_64 and arm64 architectures in one file. This means:
- ✅ One JAR works on Intel Macs
- ✅ Same JAR works on Apple Silicon Macs  
- ✅ End users don't need cmake - just use the pre-built JAR!

## Option 1: Build Universal Binary (One Time, On Mac)

If you have cmake installed (or don't mind installing it once), build a universal binary:

```bash
./build-universal-mac.sh
```

This script will:
1. Build Discord RPC for x86_64
2. Build Discord RPC for arm64  
3. Combine them into a universal binary using `lipo`
4. Replace the library in the JAR
5. Rebuild the extension

**Result:** One JAR that works everywhere!

## Option 2: Use Pre-built Universal Binary

If someone has already built a universal binary, you can use it without cmake:

```bash
./use-prebuilt-universal.sh /path/to/libdiscord-rpc-universal.dylib
./gradlew clean build
```

## Option 3: Share the Universal Binary

Once you build a universal binary, you can share it with others:

1. Build it once: `./build-universal-mac.sh`
2. The universal library will be at: `discord-rpc/libdiscord-rpc-universal.dylib`
3. Share this file - others can use it with `use-prebuilt-universal.sh`

## Benefits

- **For Builders:** Build once, share everywhere
- **For End Users:** No cmake needed - just use the JAR
- **Compatibility:** Works on both Intel and Apple Silicon Macs
- **Size:** Universal binary is larger (~2x), but still reasonable

## File Sizes

- x86_64 only: ~260 KB
- arm64 only: ~260 KB  
- Universal (both): ~520 KB (still small!)

## Verification

Check if a binary is universal:
```bash
lipo -info libdiscord-rpc-universal.dylib
# Should show: Architectures in the fat file: libdiscord-rpc-universal.dylib are: x86_64 arm64
```

## Recommended Workflow

1. **One person builds universal binary** (needs cmake once)
2. **Share the universal binary** (small file, easy to share)
3. **Everyone else uses it** (no cmake needed!)

This way, only one person needs cmake, and everyone else can just use the pre-built universal JAR!

