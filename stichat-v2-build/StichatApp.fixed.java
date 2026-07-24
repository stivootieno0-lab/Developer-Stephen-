package com.stichat.app;

import android.app.Application;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.work.Configuration;
import androidx.work.Constraints;
import androidx.work.ExistingPeriodicWorkPolicy;
import androidx.work.NetworkType;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkManager;
import java.util.concurrent.TimeUnit;

public class StichatApp extends Application implements Configuration.Provider {
    private static final String TAG = "StichatApp";
    private static StichatApp instance;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        scheduleBackgroundSyncSafely();
    }

    @NonNull
    @Override
    public Configuration getWorkManagerConfiguration() {
        return new Configuration.Builder()
                .setMinimumLoggingLevel(Log.INFO)
                .build();
    }

    private void scheduleBackgroundSyncSafely() {
        try {
            WorkManager workManager;
            try {
                workManager = WorkManager.getInstance(this);
            } catch (IllegalStateException notInitialized) {
                WorkManager.initialize(this, getWorkManagerConfiguration());
                workManager = WorkManager.getInstance(this);
            }

            Constraints constraints = new Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build();
            PeriodicWorkRequest request = new PeriodicWorkRequest.Builder(
                    SyncWorker.class,
                    15,
                    TimeUnit.MINUTES
            ).setConstraints(constraints).build();

            workManager.enqueueUniquePeriodicWork(
                    "stichat-background-sync",
                    ExistingPeriodicWorkPolicy.UPDATE,
                    request
            );
        } catch (RuntimeException startupError) {
            // Background sync must never prevent the user from opening Stichat.
            Log.e(TAG, "Background synchronization could not be scheduled during startup", startupError);
        }
    }

    public static StichatApp get() {
        return instance;
    }
}
