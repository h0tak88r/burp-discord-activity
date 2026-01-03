package burp.discordactivity;

import club.minnced.discord.rpc.DiscordRPC;
import club.minnced.discord.rpc.DiscordRichPresence;
import club.minnced.discord.rpc.DiscordEventHandlers;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.function.Consumer;

/**
 * Simple Discord Rich Presence manager.
 * Vibe coded by @imXhandle | notrubberduck.space
 * Professional Discord integration for Burp Suite
 */
public class DiscordRPCManager {
    private static final String CLIENT_ID = "1457114543028437112";
    
    private final DiscordRPC rpc;
    private final AtomicBoolean connected = new AtomicBoolean(false);
    private final ScheduledExecutorService scheduler;
    private final Consumer<String> errorLogger;
    private String lastStatus = "";
    private String lastHost = "";
    
    public DiscordRPCManager(Consumer<String> errorLogger) {
        this.rpc = DiscordRPC.INSTANCE;
        this.scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "DiscordRPC");
            t.setDaemon(true);
            return t;
        });
        this.errorLogger = errorLogger;
        
        connect();
    }
    
    private void connect() {
        try {
            DiscordEventHandlers handlers = new DiscordEventHandlers();
            handlers.ready = (user) -> connected.set(true);
            handlers.disconnected = (errorCode, message) -> connected.set(false);
            
            rpc.Discord_Initialize(CLIENT_ID, handlers, true, null);
            connected.set(true);
            
            // Keep connection alive
            scheduler.scheduleAtFixedRate(rpc::Discord_RunCallbacks, 0, 2, TimeUnit.SECONDS);
            
        } catch (Exception e) {
            errorLogger.accept("Failed to connect to Discord: " + e.getMessage());
        }
    }
    
    public void updatePresence(String status, String host, String projectName, long sessionStartTime) {
        // Vibe coded by @imXhandle | notrubberduck.space
        // Always allow updates for proxy status to prevent getting stuck
        if (status.equals(lastStatus) && host.equals(lastHost)) {
            return;
        }
        
        lastStatus = status;
        lastHost = host;
        
        if (!connected.get()) return;
        
        try {
            DiscordRichPresence presence = new DiscordRichPresence();
            presence.details = projectName; // Project name as main title
            
            // Add game timer (start timestamp) but no custom session timer text
            presence.startTimestamp = sessionStartTime;
            
            // Clean display without custom session timer
            if (host.equals("None") || host.isEmpty()) {
                presence.state = status + " • No target";
            } else {
                presence.state = status + " • " + host;
            }
            
            presence.largeImageKey = "burpsuite_icon";
            presence.largeImageText = "Burp Suite by @imXhandle";
            
            rpc.Discord_UpdatePresence(presence);
        } catch (Exception e) {
            connected.set(false);
            errorLogger.accept("Failed to update Discord: " + e.getMessage());
        }
    }
    
    public void shutdown() {
        try {
            rpc.Discord_Shutdown();
        } catch (Exception e) {
            // Ignore shutdown errors
        }
        if (scheduler != null) scheduler.shutdown();
    }
}
