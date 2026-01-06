package burp.discordactivity;

import burp.api.montoya.BurpExtension;
import burp.api.montoya.MontoyaApi;
import burp.api.montoya.extension.Extension;
import burp.api.montoya.extension.ExtensionUnloadingHandler;
import burp.api.montoya.http.handler.HttpHandler;
import burp.api.montoya.http.handler.HttpRequestToBeSent;
import burp.api.montoya.http.handler.HttpResponseReceived;
import burp.api.montoya.http.handler.RequestToBeSentAction;
import burp.api.montoya.http.handler.ResponseReceivedAction;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Minimal Burp Suite Discord Rich Presence extension.
 * Vibe coded by @imXhandle | notrubberduck.space
 * Show off your Burp Suite work on Discord with style!
 */
public class BurpDiscordActivity implements BurpExtension, HttpHandler {
    
    private MontoyaApi api;
    private DiscordRPCManager discordRPC;
    private ScheduledExecutorService scheduler;
    private String lastHost = "None";
    private boolean isActive = false;
    private long lastActivityTime = 0;
    private boolean hasSeenTarget = false;
    private String projectName = "Untitled Project";
    private long lastUpdateTime = 0;
    private static final long UPDATE_THROTTLE_MS = 1000; // 1 second throttle
    private long requestCount = 0;
    private long lastTrafficCheck = 0;
    private long sessionStartTime = 0; // Track when Burp session started
    
    @Override
    public void initialize(MontoyaApi api) {
        this.api = api;
        this.sessionStartTime = System.currentTimeMillis(); // Start session timer
        
        api.extension().setName("Burp Discord Activity");
        
        // Try to get the project name
        try {
            // Check if project name is available through the API
            projectName = api.project().name();
            if (projectName == null || projectName.isEmpty()) {
                projectName = "Burp Project";
            }
        } catch (Exception e) {
            // Fallback if project name isn't available
            projectName = "Burp Project";
            api.logging().logToError("Could not get project name: " + e.getMessage());
        }
        
        discordRPC = new DiscordRPCManager(api.logging()::logToError);
        
        api.http().registerHttpHandler(this);
        
        api.extension().registerUnloadingHandler(() -> shutdown());
        
        // Simple periodic updates
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "Discord-Updater");
            t.setDaemon(true);
            return t;
        });
        
        scheduler.scheduleAtFixedRate(() -> {
            try {
                updatePresence();
            } catch (Exception e) {
                api.logging().logToError("Error in Discord presence update: " + e.getMessage());
                e.printStackTrace();
            }
        }, 0, 30, TimeUnit.SECONDS);
        
        api.logging().logToOutput("Burp Discord Activity loaded - Project: " + projectName);
        api.logging().logToOutput("Vibe coded by @imXhandle | notrubberduck.space");
    }
    
    private void updatePresence() {
        // Vibe coded by @imXhandle | notrubberduck.space
        try {
            // Check for idle (5 minutes = 300000 ms)
            long now = System.currentTimeMillis();
            if (isActive && (now - lastActivityTime) > 300000) {
                isActive = false;
            }
            
            String status = isActive ? "Proxy" : "Idle";
            
            // Don't show target domain for privacy - just show status
            discordRPC.updatePresence(status, "", projectName, sessionStartTime);
        } catch (Exception e) {
            api.logging().logToError("Error updating Discord presence: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    @Override
    public RequestToBeSentAction handleHttpRequestToBeSent(HttpRequestToBeSent request) {
        String host = request.httpService().host();
        if (host != null && !host.isEmpty()) {
            lastHost = host;
            hasSeenTarget = true;
            isActive = true;
            lastActivityTime = System.currentTimeMillis();
            
            // Check if target is in scope
            boolean inScope = api.scope().isInScope(request.url());
            if (inScope) {
                lastHost = host;
            }
            
            // Smart throttling based on traffic volume
            requestCount++;
            long currentTime = System.currentTimeMillis();
            
            // Reset traffic counter every 10 seconds
            if ((currentTime - lastTrafficCheck) > 10000) {
                requestCount = 0;
                lastTrafficCheck = currentTime;
            }
            
            // Adjust throttle based on traffic volume
            long throttleTime = UPDATE_THROTTLE_MS;
            if (requestCount > 100) {
                throttleTime = 3000; // 3 seconds for heavy traffic
            } else if (requestCount > 50) {
                throttleTime = 2000; // 2 seconds for medium traffic
            }
            
            if ((currentTime - lastUpdateTime) > throttleTime) {
                lastUpdateTime = currentTime;
                try {
                    updatePresence();
                } catch (Exception e) {
                    api.logging().logToError("Error updating presence from request handler: " + e.getMessage());
                }
            }
        }
        return RequestToBeSentAction.continueWith(request);
    }
    
    @Override
    public ResponseReceivedAction handleHttpResponseReceived(HttpResponseReceived response) {
        return ResponseReceivedAction.continueWith(response);
    }
    
    private void shutdown() {
        try {
            if (scheduler != null) {
                scheduler.shutdown();
                try {
                    if (!scheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                        scheduler.shutdownNow();
                    }
                } catch (InterruptedException e) {
                    scheduler.shutdownNow();
                    Thread.currentThread().interrupt();
                }
            }
            if (discordRPC != null) {
                discordRPC.shutdown();
            }
            api.logging().logToOutput("Burp Discord Activity unloaded - @imXhandle | notrubberduck.space");
        } catch (Exception e) {
            api.logging().logToError("Error during shutdown: " + e.getMessage());
        }
    }
}

