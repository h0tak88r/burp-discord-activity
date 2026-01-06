# Building the Extension

## Prerequisites

You need:
- ✅ **Montoya API JAR** - Already downloaded to `libs/montoya-api-2025.12.jar`
- ✅ **Discord RPC library** - Already in `libs/java-discord-rpc-2.0.1-all.jar`
- **Java 17 or higher** - Required for building
- **Gradle Wrapper** - Included in the project (no installation needed!)

## Step 1: Build the Extension

The project includes a Gradle wrapper, so you don't need to install Gradle separately. Simply run:

```bash
./gradlew clean build
```

On Windows:
```bash
gradlew.bat clean build
```

The wrapper will automatically download Gradle if needed.

### Building on Mac Apple Silicon (M1/M2/M3)

The build process works the same on Apple Silicon. The JAR file is platform-independent and will work on any platform. However, when **running** the extension on Apple Silicon:

1. **Ensure Java is ARM64**: Make sure you're using an ARM64 Java runtime, not x86_64 running under Rosetta
   ```bash
   java -version
   # Should show arm64 or aarch64 architecture
   ```

2. **Verify Burp Suite is native**: Burp Suite should be running natively on Apple Silicon, not under Rosetta
   - Check Activity Monitor → Burp Suite process → "Kind" column should say "Apple"

3. **Discord RPC library**: The `java-discord-rpc-2.0.1-all.jar` includes native libraries for multiple platforms including arm64. If you encounter `UnsatisfiedLinkError`, see `APPLE_SILICON.md` for troubleshooting.

### Alternative: Install Gradle System-Wide (Optional)

If you prefer to use a system-wide Gradle installation instead of the wrapper:

#### Option A: Using Homebrew (macOS)
```bash
brew install gradle
```

#### Option B: Using SDKMAN
```bash
curl -s "https://get.sdkman.io" | bash
sdk install gradle
```

#### Option C: Manual Installation
1. Download Gradle from https://gradle.org/releases/
2. Extract and add to PATH

Then use:
```bash
gradle clean build
```

## Step 3: Find the Built Extension

After building, the extension JAR will be at:
```
build/libs/BurpDiscordActivity-1.0.0.jar
```

## Step 4: Load in Burp Suite

1. Open **Burp Suite**
2. Go to **Extensions** tab
3. Click **Add**
4. Select **Java** as extension type
5. Click **Select file** and choose `build/libs/BurpDiscordActivity-1.0.0.jar`
6. The extension should load successfully!

## Troubleshooting

### "gradle: command not found"
- Install Gradle using one of the methods above
- Make sure it's in your PATH

### Build errors about missing dependencies
- Verify both JAR files are in the `libs/` directory:
  - `libs/montoya-api-2025.12.jar`
  - `libs/java-discord-rpc-2.0.1-all.jar`

### Apple Silicon native library errors
- See `APPLE_SILICON.md` for detailed troubleshooting steps
- Make sure you have the latest Discord RPC library with arm64 support
- Verify Burp Suite is running natively (not under Rosetta)
- Ensure Java runtime is ARM64, not x86_64

