# Apple Silicon (M1/M2/M3) Compatibility

## Issue

If you're running Burp Suite on Apple Silicon Macs (M1, M2, M3, etc.), you may encounter native library errors when loading the extension:

```
java.lang.UnsatisfiedLinkError: ... missing compatible architecture (have 'i386,x86_64', need 'arm64e' or 'arm64e.v1' or 'arm64' or 'arm64')
```

This happens because the Discord RPC library (`java-discord-rpc`) includes native libraries that may not have arm64 support in older versions.

## Solutions

### Option 1: Use Latest Library Version

1. Download the latest `java-discord-rpc-2.0.1-all.jar` from:
   https://github.com/MinnDevelopment/java-discord-rpc/releases

2. Make sure you get the **"all"** version (includes native libraries)

3. Replace the file in `libs/java-discord-rpc-2.0.1-all.jar`

4. Rebuild the extension:
   ```bash
   ./gradlew clean build
   ```

### Option 2: Check Java Runtime

Ensure you're using a Java runtime that supports Apple Silicon:

1. Check your Java version:
   ```bash
   java -version
   ```

2. Make sure you're using an arm64 Java build, not x86_64 running under Rosetta

3. Burp Suite should automatically use the correct Java runtime, but verify in Burp Suite's About dialog

### Option 3: Run Burp Suite Natively

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

If errors persist, the Discord RPC library may need to be updated by its maintainers to fully support Apple Silicon.

## Privacy Note

The extension has been updated to **not display target domains** in Discord status for privacy. Only the activity status (Proxy/Idle) and project name are shown.

