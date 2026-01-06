# Apple Silicon (M1/M2/M3) Compatibility

## Issue

If you're running Burp Suite on Apple Silicon Macs (M1, M2, M3, etc.), you may encounter native library errors when loading the extension:

```
java.lang.UnsatisfiedLinkError: ... missing compatible architecture (have 'i386,x86_64', need 'arm64e' or 'arm64e.v1' or 'arm64' or 'arm64')
```

This happens because the Discord RPC library (`java-discord-rpc-2.0.1-all.jar`) includes native libraries that are **x86_64 only** and do not support arm64.

## Root Cause

The `java-discord-rpc-2.0.1-all.jar` library contains:
- `darwin/libdiscord-rpc.dylib` - built for x86_64 only (from 2018, before Apple Silicon)
- Old JNA (Java Native Access) library without arm64 support

## Solutions

### Option 1: Build and Replace arm64 Native Library (Recommended)

**See `APPLE_SILICON_FIX.md` for detailed step-by-step instructions.**

This involves:
1. Building the Discord RPC native library for arm64 from source
2. Replacing the x86_64 library in the JAR file
3. Rebuilding the extension

This is the proper solution that will work natively on Apple Silicon.

### Option 2: Run Under Rosetta 2 (Temporary Workaround)

As a temporary workaround, you can run Burp Suite under Rosetta 2:

1. **Check if Burp Suite is running under Rosetta:**
   - Open Activity Monitor
   - Find Burp Suite process
   - Check the "Kind" column

2. **If it says "Apple", force it to run under Rosetta:**
   - Right-click Burp Suite in Applications
   - Select "Get Info"
   - Check "Open using Rosetta"
   - Restart Burp Suite

**Note:** This will reduce performance and is not recommended for long-term use.

### Option 3: Check Java Runtime

Ensure you're using a Java runtime that supports Apple Silicon:

1. Check your Java version:
   ```bash
   java -version
   ```

2. Make sure you're using an arm64 Java build, not x86_64 running under Rosetta

3. Burp Suite should automatically use the correct Java runtime, but verify in Burp Suite's About dialog

### Option 4: Verify Burp Suite is Native

Make sure Burp Suite itself is running natively on Apple Silicon, not under Rosetta:

1. Check if Burp Suite is running under Rosetta:
   - Open Activity Monitor
   - Find Burp Suite process
   - Check the "Kind" column - should say "Apple" not "Intel"

2. If it says "Intel", you may need to:
   - Reinstall Burp Suite
   - Ensure you downloaded the Apple Silicon version
   - Check PortSwigger's download page for the correct architecture

## Verification

After applying fixes, check Burp Suite's **Errors** tab. You should see:
- "Burp Discord Activity loaded" in the Output tab
- No UnsatisfiedLinkError in the Errors tab

## JNA Update

The build configuration has been updated to include JNA 5.13.0, which has arm64 support. This will automatically override the old JNA included in the Discord RPC library. However, you still need to replace the Discord RPC native library itself (see Option 1 above).

If errors persist after following Option 1, the Discord RPC library may need to be updated by its maintainers to fully support Apple Silicon.

## Privacy Note

The extension has been updated to **not display target domains** in Discord status for privacy. Only the activity status (Proxy/Idle) and project name are shown.

