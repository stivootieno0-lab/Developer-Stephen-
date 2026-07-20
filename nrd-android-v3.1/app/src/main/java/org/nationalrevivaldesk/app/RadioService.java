package org.nationalrevivaldesk.app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.media.AudioAttributes;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.IBinder;

public final class RadioService extends Service {
    public static final String ACTION_PLAY = "org.nationalrevivaldesk.action.PLAY";
    public static final String ACTION_STOP = "org.nationalrevivaldesk.action.STOP";
    public static final String EXTRA_STREAM = "stream";
    private static final String CHANNEL_ID = "nrd_radio";
    private static final int NOTIFICATION_ID = 701;
    private MediaPlayer player;
    private String currentStream = "https://s3.radio.co/s97f38db97/listen";

    @Override public void onCreate() {
        super.onCreate();
        createChannel();
    }

    @Override public int onStartCommand(Intent intent, int flags, int startId) {
        String action = intent == null ? ACTION_PLAY : intent.getAction();
        if (ACTION_STOP.equals(action)) {
            stopRadio();
            stopForeground(true);
            stopSelf();
            return START_NOT_STICKY;
        }
        if (intent != null) {
            String requested = intent.getStringExtra(EXTRA_STREAM);
            if (requested != null && !requested.trim().isEmpty()) currentStream = requested.trim();
        }
        startForeground(NOTIFICATION_ID, buildNotification());
        play(currentStream);
        return START_STICKY;
    }

    private void play(String stream) {
        if (player != null && player.isPlaying()) return;
        stopRadio();
        try {
            player = new MediaPlayer();
            player.setAudioAttributes(new AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .build());
            player.setDataSource(stream);
            player.setOnPreparedListener(MediaPlayer::start);
            player.setOnCompletionListener(ignored -> reconnect());
            player.setOnErrorListener((mediaPlayer, what, extra) -> { reconnect(); return true; });
            player.prepareAsync();
        } catch (Exception ignored) {
            reconnect();
        }
    }

    private void reconnect() {
        stopRadio();
        new android.os.Handler(getMainLooper()).postDelayed(() -> play(currentStream), 5000);
    }

    private void stopRadio() {
        if (player == null) return;
        try { player.stop(); } catch (Exception ignored) { }
        try { player.release(); } catch (Exception ignored) { }
        player = null;
    }

    private Notification buildNotification() {
        Intent open = new Intent(this, MainActivity.class);
        PendingIntent openPending = PendingIntent.getActivity(this, 1, open,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        Intent stop = new Intent(this, RadioService.class).setAction(ACTION_STOP);
        PendingIntent stopPending = PendingIntent.getService(this, 2, stop,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        Notification.Builder builder = Build.VERSION.SDK_INT >= 26
                ? new Notification.Builder(this, CHANNEL_ID)
                : new Notification.Builder(this);
        return builder
                .setContentTitle("Jesus is LORD Radio")
                .setContentText("National Revival Desk live radio is playing")
                .setSmallIcon(R.drawable.nrd_logo)
                .setContentIntent(openPending)
                .addAction(R.drawable.nrd_logo, "Stop", stopPending)
                .setOngoing(true)
                .setCategory(Notification.CATEGORY_TRANSPORT)
                .build();
    }

    private void createChannel() {
        if (Build.VERSION.SDK_INT >= 26) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID, "Radio Playback", NotificationManager.IMPORTANCE_LOW);
            channel.setDescription("Keeps Jesus is LORD Radio playing in the background");
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) manager.createNotificationChannel(channel);
        }
    }

    @Override public IBinder onBind(Intent intent) { return null; }
    @Override public void onDestroy() { stopRadio(); super.onDestroy(); }
}
