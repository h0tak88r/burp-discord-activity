# Building the Extension

## Prerequisites

You need:
- ✅ **Montoya API JAR** - Already downloaded to `libs/montoya-api-2025.12.jar`
- ✅ **Discord RPC library** - Already in `libs/java-discord-rpc-2.0.1-all.jar`
- **Gradle** - Build tool (see installation below)

## Step 1: Install Gradle

### Option A: Using Homebrew (macOS)
```bash
brew install gradle
```

### Option B: Using SDKMAN
```bash
curl -s "https://get.sdkman.io" | bash
sdk install gradle
```

### Option C: Manual Installation
1. Download Gradle from https://gradle.org/releases/
2. Extract and add to PATH

### Verify Installation
```bash
gradle --version
```

## Step 2: Build the Extension

Once Gradle is installed, run:

```bash
cd /Volumes/External/sallam/Documents/burp-discord-activity
gradle clean build
```

Or if you prefer using the wrapper (after creating it):
```bash
./gradlew clean build
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
- See `APPLE_SILICON.md` for troubleshooting steps
- Make sure you have the latest Discord RPC library

