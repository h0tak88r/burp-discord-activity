# Fork and Push Guide

## Step 1: Fork the Repository on GitHub

1. Go to https://github.com/Hunt3r0x/burp-discord-activity
2. Click the **"Fork"** button in the top right
3. Choose where to fork it (your personal account or an organization)
4. Wait for the fork to complete

## Step 2: Update Git Remote

After forking, you'll have a new repository URL like:
`https://github.com/YOUR_USERNAME/burp-discord-activity.git`

Update the remote:

```bash
cd /Volumes/External/sallam/Documents/burp-discord-activity
git remote set-url origin https://github.com/YOUR_USERNAME/burp-discord-activity.git
```

Or add it as a new remote (keeping original as upstream):

```bash
git remote rename origin upstream
git remote add origin https://github.com/YOUR_USERNAME/burp-discord-activity.git
```

## Step 3: Stage Your Changes

```bash
git add README.md
git add build.gradle
git add src/main/java/burp/discordactivity/BurpDiscordActivity.java
git add src/main/java/burp/discordactivity/DiscordRPCManager.java
git add APPLE_SILICON.md
git add BUILD.md
```

Or stage all changes:
```bash
git add .
```

## Step 4: Commit Your Changes

```bash
git commit -m "Add privacy improvements and Apple Silicon compatibility

- Remove target domain display from Discord status for privacy
- Add better error handling for Apple Silicon native library issues
- Add APPLE_SILICON.md troubleshooting guide
- Add BUILD.md build instructions
- Update build.gradle to use local Montoya API JAR"
```

## Step 5: Push to Your Fork

```bash
git push origin main
```

Or if you renamed the remote:
```bash
git push origin main
```

## Summary of Changes

Your fork includes these improvements:

1. **Privacy Enhancement**: Target domains are no longer displayed in Discord status
2. **Apple Silicon Support**: Better error handling and troubleshooting guide
3. **Build Instructions**: Added BUILD.md for easier setup
4. **Local Dependencies**: Updated to use local Montoya API JAR

## Optional: Create a Pull Request

If you want to contribute back to the original repository:

1. Go to your fork on GitHub
2. Click **"Contribute"** → **"Open Pull Request"**
3. Describe your changes
4. Submit the PR

