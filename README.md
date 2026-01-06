# Burp Discord Activity

Show off your Burp Suite work on Discord! This extension updates your Discord status to show what tools you're using and what target you're testing.

![Screenshot 2026-01-04 004221.png](https://files.catbox.moe/hbpntc.png)

**Vibe coded by [@imXhandle](https://twitter.com/imXhandle) | [notrubberduck.space](https://notrubberduck.space)**

## What the Extension Does

Burp Discord Activity is a Burp Suite extension that displays your security testing activity on Discord Rich Presence. It provides real-time updates about your Burp Suite session, including:

- **Active Tool Status**: Shows when you're actively using Burp Suite (Proxy mode) or when you're idle
- **Activity Status**: Shows your current activity status (Proxy/Idle) without revealing target domains for privacy
- **Project Name**: Displays your current Burp Suite project name in the Discord status
- **Idle Detection**: Automatically switches to "Idle" status after 5 minutes of no activity
- **Automatic Reconnection**: Handles Discord connection issues gracefully and reconnects automatically

The extension monitors your Burp Suite activity and updates your Discord status in real-time, giving others a glimpse into your security testing work.

## How It Works

The extension operates through several key components working together:

### Architecture Overview

1. **HTTP Request Interception**: The extension registers as an HTTP handler with Burp Suite's Montoya API, intercepting all HTTP requests sent through Burp Suite tools.

2. **Target Domain Extraction**: From each intercepted HTTP request, the extension extracts the target host/domain. It maintains a history of the last 20 target hosts and determines the most common target to display.

3. **Activity Tracking**: The extension tracks when requests are being sent, marking the session as "active". If no requests are detected for 5 minutes, the status automatically switches to "Idle".

4. **Discord RPC Integration**: The extension uses Discord's Rich Presence API via local IPC (Inter-Process Communication). This means:
   - Communication happens entirely on your local machine
   - No internet connection is required for Discord communication (beyond Discord's normal operation)
   - Updates are sent directly to the Discord desktop application running on your computer

5. **Update Throttling**: To prevent performance issues during high-traffic testing, the extension implements intelligent throttling:
   - Normal traffic: Updates every 1 second
   - Medium traffic (50+ requests/10s): Updates every 2 seconds
   - Heavy traffic (100+ requests/10s): Updates every 3 seconds
   - Background updates: Every 30 seconds regardless of activity

6. **Project Information**: The extension retrieves your Burp Suite project name from the Montoya API and displays it as the main status title in Discord.

### Data Flow

```
HTTP Request → Burp Suite → Extension Handler → Target Extraction → Activity Tracking → Discord RPC (Local IPC) → Discord Desktop App
```

All processing happens locally on your machine. The only external communication is with Discord via local IPC, which is handled by Discord's desktop application.

## Installation & Usage

### Prerequisites

- **Java 17 or higher**: Required for building and running the extension
- **Burp Suite**: Pro or Community edition with Montoya API support (see Burp Version Compatibility section)
- **Discord Desktop App**: The extension requires the Discord desktop application to be running (Discord web browser version will not work)

### Building the Extension

1. **Clone or download** this repository
2. **Download required dependencies** (if not already present):
   - Montoya API JAR: Download from [PortSwigger's releases](https://github.com/PortSwigger/burp-extensions-montoya-api/releases) and place in `libs/` directory
   - Discord RPC library: Download `java-discord-rpc-2.0.1-all.jar` from [MinnDevelopment's releases](https://github.com/MinnDevelopment/java-discord-rpc/releases) and place in `libs/` directory
3. **Build the extension**:
   - On Windows: `gradlew.bat clean build`
   - On Linux/Mac: `./gradlew clean build`
4. **Find the JAR**: The built extension will be at `build/libs/BurpDiscordActivity-1.0.0.jar`

### Installing in Burp Suite

1. **Open Burp Suite** (Pro or Community edition)
2. Navigate to **Extensions** tab
3. Click **Add** button
4. In the extension type dropdown, select **Java**
5. Click **Select file** and choose `BurpDiscordActivity-1.0.0.jar` from the `build/libs/` directory
6. The extension should load successfully (check the Output tab for confirmation)

### Using the Extension

1. **Start Discord Desktop App**: Make sure Discord is running on your computer
2. **Load the extension** in Burp Suite (see installation steps above)
3. **Start your security testing**: The extension will automatically:
   - Detect when you send HTTP requests through Burp Suite
   - Extract target domains from your requests
   - Update your Discord status in real-time
4. **Check your Discord status**: Your Discord friends will see:
   - **Details**: Your Burp Suite project name
   - **State**: Current activity status (e.g., "Proxy" or "Idle")
   - **Session Timer**: How long you've been working in this Burp Suite session

### Troubleshooting

- **Discord not updating?**
  - Ensure Discord desktop app is running (not just the web browser version)
  - Check that Discord Rich Presence is enabled in Discord settings
  - Restart Discord if the connection seems stuck

- **Extension not loading?**
  - Check Burp Suite's **Errors** tab for detailed error messages
  - Verify you have Java 17+ installed
  - Ensure all dependencies are in the `libs/` directory
  - Make sure you're using a compatible Burp Suite version (see Burp Version Compatibility)

- **Apple Silicon (M1/M2/M3) compatibility issues?**
  - If you see `UnsatisfiedLinkError` with "arm64" or "arm64e" errors, the Discord RPC library may not have native libraries for Apple Silicon
  - Try downloading the latest version of `java-discord-rpc-2.0.1-all.jar` from the [releases page](https://github.com/MinnDevelopment/java-discord-rpc/releases)
  - Ensure you're using the "all" version which includes native libraries
  - If issues persist, check that your Java runtime supports the architecture

- **Status stuck on "Idle"?**
  - Send a request through Burp Suite to reactivate the extension
  - Check that the extension is still loaded in Burp Suite's Extensions tab

## Burp Version Compatibility

### Montoya API Support

This extension requires **Burp Suite with Montoya API support**. The Montoya API was introduced in **Burp Suite 2023.9** and is the modern extension API for Burp Suite.

### Current Version

- **Tested with**: Montoya API 2025.12
- **Minimum Burp Suite version**: 2023.9 (when Montoya API was introduced)
- **Recommended**: Latest Burp Suite version for best compatibility

### Checking Your Burp Suite Version

1. Open Burp Suite
2. Go to **Help** → **About Burp Suite**
3. Check the version number
4. If your version is 2023.9 or later, you can use the standard version of this extension

## External Services

### Discord Rich Presence

The extension uses **Discord Rich Presence** to display your activity status. This integration works as follows:

- **Communication Method**: Local IPC (Inter-Process Communication)
- **No Internet Required**: The extension communicates directly with the Discord desktop application on your local machine
- **No External API Calls**: All communication happens locally - no data is sent to external web services
- **Client ID**: The extension uses a registered Discord application client ID (`1457114543028437112`) to identify itself to Discord

### What Data is Sent to Discord

The extension sends the following information to Discord (via local IPC):

- **Project Name**: Your current Burp Suite project name
- **Target Domain**: The most common target domain from your recent requests
- **Activity Status**: Whether you're "Proxy" (active) or "Idle"
- **Session Start Time**: When your Burp Suite session started (for the session timer)

### Other Services

- **No Slack Integration**: This extension does not integrate with Slack. It only supports Discord Rich Presence.
- **No External APIs**: The extension does not make any HTTP requests to external web services or APIs
- **No Cloud Services**: All processing and communication happens locally on your machine

### Offline Working Limitations

**Note**: This extension requires the Discord desktop application to be installed and running on your machine. While the extension uses local IPC (no internet connection required for the extension itself), it does require:

- Discord desktop app to be installed (Discord web browser version will not work)
- Discord desktop app to be running while using the extension
- The extension will not function in completely offline environments where Discord desktop app cannot run

If you need to work in a completely offline environment without Discord, this extension will not be suitable for your use case.

## Privacy / Data Handling

### Data Collection

This extension **does not collect, store, or transmit any data** to external servers or services. All processing happens locally on your machine.

### What Data is Processed

The extension processes the following data locally:

- **HTTP Request Headers**: To extract target host/domain information
- **Request Counts**: To determine the most common target (last 20 requests)
- **Activity Timestamps**: To detect idle state (5-minute timeout)
- **Project Name**: Retrieved from Burp Suite's API

### What Data is Shared

The only data shared is with Discord via local IPC:

- **Project Name**: Your Burp Suite project name (visible to Discord friends)
- **Target Domain**: The domain you're testing (visible to Discord friends)
- **Activity Status**: Active or Idle state (visible to Discord friends)
- **Session Duration**: How long your session has been active (visible to Discord friends)

### Privacy Guarantees

- **No Telemetry**: The extension does not send any usage statistics or telemetry data
- **No Analytics**: No analytics or tracking is performed
- **No External Logging**: No data is logged to external services
- **No Data Storage**: The extension does not store any data persistently
- **Local Only**: All communication is local (Discord IPC) - no internet connection required for extension operation
- **Open Source**: The source code is available for review

### Security Considerations

- **Target Domain Visibility**: Be aware that the target domain you're testing will be visible to anyone who can see your Discord status
- **Project Name Visibility**: Your Burp Suite project name will be visible in your Discord status
- **No Sensitive Data**: The extension only extracts host/domain names from requests - it does not access request bodies, response data, or any sensitive information

### Recommendations

- Consider your organization's policies regarding sharing testing activities
- Be mindful that target domains may reveal information about your security testing scope
- If privacy is a concern, you can disable Discord Rich Presence in Discord settings while using this extension

## License

Free to use for educational and professional purposes.

## Author

Vibe coded by **[@imXhandle](https://twitter.com/imXhandle)** | **[notrubberduck.space](https://notrubberduck.space)**
