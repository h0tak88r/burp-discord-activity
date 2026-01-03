package burp.discordactivity;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * Tracks active Burp Suite tools, target hosts, and idle state.
 */
public class ActivityTracker {
    private static final int IDLE_TIMEOUT_MINUTES = 5;
    private static final int HOST_HISTORY_SIZE = 20; // Reduced from 50
    private static final int UPDATE_INTERVAL_SECONDS = 15; // Reduced frequency
    
    private final Set<ToolState> activeTools;
    private final Queue<String> hostHistory;
    private final ScheduledExecutorService scheduler;
    private volatile ScheduledFuture<?> idleTask; // Volatile for thread safety
    private final Runnable onIdleCallback;
    
    // Cache for frequently accessed data
    private volatile String cachedMostCommonHost;
    private volatile long lastHostUpdate = 0;
    private static final long HOST_CACHE_DURATION_MS = 30000; // 30 seconds
    
    public ActivityTracker(Runnable onIdleCallback) {
        this.activeTools = Collections.newSetFromMap(new ConcurrentHashMap<>());
        this.hostHistory = new ConcurrentLinkedQueue<>();
        this.scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "ActivityTracker-IdleTimer");
            t.setDaemon(true);
            return t;
        });
        this.onIdleCallback = onIdleCallback;
    }
    
    /**
     * Marks a tool as active and resets the idle timer.
     */
    public synchronized void activateTool(ToolState tool) {
        if (tool != ToolState.IDLE) {
            activeTools.add(tool);
            resetIdleTimer();
        }
    }
    
    /**
     * Marks a tool as inactive.
     */
    public synchronized void deactivateTool(ToolState tool) {
        activeTools.remove(tool);
        if (activeTools.isEmpty()) {
            resetIdleTimer();
        }
    }
    
    /**
     * Records a new host and resets the idle timer.
     */
    public synchronized void recordHost(String host) {
        if (host == null || host.isEmpty()) {
            return;
        }
        
        // Invalidate cache when new host is added
        cachedMostCommonHost = null;
        
        // Add to history with size limit
        hostHistory.offer(host);
        while (hostHistory.size() > HOST_HISTORY_SIZE) {
            hostHistory.poll();
        }
        
        resetIdleTimer();
    }
    
    /**
     * Gets the most common host from recent requests (with caching).
     */
    public synchronized String getMostCommonHost() {
        long currentTime = System.currentTimeMillis();
        
        // Return cached value if still valid
        if (cachedMostCommonHost != null && (currentTime - lastHostUpdate) < HOST_CACHE_DURATION_MS) {
            return cachedMostCommonHost;
        }
        
        if (hostHistory.isEmpty()) {
            cachedMostCommonHost = "None";
            lastHostUpdate = currentTime;
            return cachedMostCommonHost;
        }
        
        // Count hosts efficiently
        Map<String, Integer> hostCounts = new HashMap<>();
        for (String host : hostHistory) {
            hostCounts.merge(host, 1, Integer::sum);
        }
        
        // Find most common host
        String mostCommon = hostCounts.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("None");
        
        // Update cache
        cachedMostCommonHost = mostCommon;
        lastHostUpdate = currentTime;
        
        return mostCommon;
    }
    
    /**
     * Gets the formatted tool names for Discord display.
     */
    public synchronized String getFormattedToolNames() {
        if (activeTools.isEmpty()) {
            return ToolState.IDLE.getDisplayName();
        }
        
        return activeTools.stream()
                .sorted(Comparator.comparing(ToolState::ordinal))
                .map(ToolState::getDisplayName)
                .collect(Collectors.joining(", "));
    }
    
    /**
     * Checks if any tools are currently active.
     */
    public synchronized boolean hasActiveTools() {
        return !activeTools.isEmpty();
    }
    
    /**
     * Resets the idle timer.
     */
    private synchronized void resetIdleTimer() {
        if (idleTask != null) {
            idleTask.cancel(false);
        }
        
        idleTask = scheduler.schedule(() -> {
            synchronized (this) {
                activeTools.clear();
                if (onIdleCallback != null) {
                    onIdleCallback.run();
                }
            }
        }, IDLE_TIMEOUT_MINUTES, TimeUnit.MINUTES);
    }
    
    /**
     * Shuts down the activity tracker and cleans up resources.
     */
    public void shutdown() {
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
}

