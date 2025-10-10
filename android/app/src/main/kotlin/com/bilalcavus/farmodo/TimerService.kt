package com.bilalcavus.farmodo

import android.app.*
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.app.NotificationCompat
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.*
import kotlin.concurrent.schedule

class TimerService : Service() {
    private var wakeLock: PowerManager.WakeLock? = null
    private var timer: Timer? = null
    private var isRunning = false
    private var secondsRemaining = 0
    private var totalSeconds = 0
    private var isOnBreak = false
    private var taskTitle = ""
    private var mediaPlayer: MediaPlayer? = null
    
    companion object {
        const val ACTION_START_TIMER = "ACTION_START_TIMER"
        const val ACTION_PAUSE_TIMER = "ACTION_PAUSE_TIMER"
        const val ACTION_RESUME_TIMER = "ACTION_RESUME_TIMER"
        const val ACTION_STOP_TIMER = "ACTION_STOP_TIMER"
        const val EXTRA_SECONDS_REMAINING = "EXTRA_SECONDS_REMAINING"
        const val EXTRA_TOTAL_SECONDS = "EXTRA_TOTAL_SECONDS"
        const val EXTRA_IS_ON_BREAK = "EXTRA_IS_ON_BREAK"
        const val EXTRA_TASK_TITLE = "EXTRA_TASK_TITLE"
        
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "pomodoro_timer_channel"
        private const val CHANNEL_NAME = "Pomodoro Timer"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        acquireWakeLock()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_TIMER -> {
                secondsRemaining = intent.getIntExtra(EXTRA_SECONDS_REMAINING, 0)
                totalSeconds = intent.getIntExtra(EXTRA_TOTAL_SECONDS, 0)
                isOnBreak = intent.getBooleanExtra(EXTRA_IS_ON_BREAK, false)
                taskTitle = intent.getStringExtra(EXTRA_TASK_TITLE) ?: "No active task"
                startTimer()
            }
            ACTION_PAUSE_TIMER -> {
                pauseTimer()
            }
            ACTION_RESUME_TIMER -> {
                resumeTimer()
            }
            ACTION_STOP_TIMER -> {
                stopTimer()
            }
        }
        return START_STICKY
    }

    private fun startTimer() {
        if (isRunning) return
        
        isRunning = true
        
        // Foreground service olarak başlatmayı dene
        try {
            startForeground(NOTIFICATION_ID, createNotification())
        } catch (e: Exception) {
            // Android 12+ restriction: Sadece notification göster
            android.util.Log.w("TimerService", "Cannot start as foreground service: ${e.message}")
            try {
                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.notify(NOTIFICATION_ID, createNotification())
            } catch (ne: Exception) {
                android.util.Log.e("TimerService", "Cannot show notification: ${ne.message}")
            }
        }
        
        timer = Timer()
        timer?.schedule(0, 1000) {
            if (secondsRemaining > 0) {
                secondsRemaining--
                
                // Bildirimi her 3 saniyede bir güncelle (performans ve stabilite için)
                if (secondsRemaining % 3 == 0 || secondsRemaining == totalSeconds - 1) {
                    updateNotification()
                }
                
                // Widget'ı her 5 saniyede bir güncelle
                if (secondsRemaining % 5 == 0) {
                    updateWidget()
                    saveTimerState()
                }
            } else {
                // Timer bitti
                onTimerComplete()
            }
        }
    }

    private fun pauseTimer() {
        isRunning = false
        timer?.cancel()
        timer = null
        updateNotification()
        updateWidget()
        saveTimerState()
    }

    private fun resumeTimer() {
        if (secondsRemaining > 0) {
            startTimer()
        }
    }

    private fun stopTimer() {
        isRunning = false
        timer?.cancel()
        timer = null
        try {
            stopForeground(true)
        } catch (e: Exception) {
            android.util.Log.w("TimerService", "Error stopping foreground: ${e.message}")
        }
        stopSelf()
    }

    private fun onTimerComplete() {
        isRunning = false
        timer?.cancel()
        timer = null
        
        // Tamamlanma sesini çal ve titreşim
        playCompletionSound()
        vibrateCompletion()
        
        // Break moduna geç veya timer'ı durdur
        showCompletionNotification()
        updateWidget()
        
        try {
            stopForeground(true)
        } catch (e: Exception) {
            android.util.Log.w("TimerService", "Error stopping foreground: ${e.message}")
        }
        stopSelf()
    }

    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val timeText = formatTime(secondsRemaining)
        val status = if (isOnBreak) "Break" else "Work"

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(timeText)
            .setContentText("$status • $taskTitle")
            .setSmallIcon(R.drawable.ic_notification)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .build()
    }

    private fun updateNotification() {
        val notification = createNotification()
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun showCompletionNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val title = "Timer Completed!"
        val message = if (isOnBreak) {
            "Break time finished! Ready to focus?"
        } else {
            "Work session finished! Time for a break!"
        }
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(R.drawable.ic_notification)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .build()
        
        notificationManager.notify(NOTIFICATION_ID + 1, notification)
    }
    
    private fun playCompletionSound() {
        try {
            // Önceki media player'ı tamamen temizle
            try {
                mediaPlayer?.stop()
            } catch (e: Exception) {
                // Ignore
            }
            mediaPlayer?.release()
            mediaPlayer = null
            
            // AudioManager kontrolü
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
            android.util.Log.d("TimerService", "🔊 Current volume: $currentVolume")
            
            // Yeni media player oluştur
            mediaPlayer = MediaPlayer()
            
            // Audio attributes ayarla (Android 5.0+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                mediaPlayer?.setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                        .build()
                )
            } else {
                @Suppress("DEPRECATION")
                mediaPlayer?.setAudioStreamType(AudioManager.STREAM_NOTIFICATION)
            }
            
            // Ses dosyasını yükle
            val afd = resources.openRawResourceFd(R.raw.complete_sound)
            mediaPlayer?.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            afd.close()
            
            // Prepare ve play
            mediaPlayer?.prepare()
            
            mediaPlayer?.setOnCompletionListener { mp ->
                try {
                    mp.release()
                } catch (e: Exception) {
                    android.util.Log.e("TimerService", "Error releasing MediaPlayer: ${e.message}")
                }
                mediaPlayer = null
                android.util.Log.d("TimerService", "✅ Sound playback completed")
            }
            
            mediaPlayer?.setOnErrorListener { mp, what, extra ->
                android.util.Log.e("TimerService", "❌ MediaPlayer error: what=$what, extra=$extra")
                mp.release()
                mediaPlayer = null
                true
            }
            
            mediaPlayer?.start()
            android.util.Log.d("TimerService", "✅ Sound playing successfully")
            
        } catch (e: Exception) {
            android.util.Log.e("TimerService", "❌ Error playing sound: ${e.message}", e)
            mediaPlayer?.release()
            mediaPlayer = null
        }
    }
    
    private fun vibrateCompletion() {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            
            // Titreşim deseni: [Bekle, Titre, Bekle, Titre, Bekle, Titre]
            // 3 kez kısa titreşim
            val pattern = longArrayOf(0, 200, 100, 200, 100, 200)
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createWaveform(pattern, -1))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(pattern, -1)
            }
        } catch (e: Exception) {
            android.util.Log.e("TimerService", "Error vibrating: ${e.message}")
        }
    }

    private fun updateWidget() {
        val widgetData = HomeWidgetPlugin.getData(this)
        widgetData.edit().apply {
            putBoolean("timer_running", isRunning)
            putInt("seconds_remaining", secondsRemaining)
            putBoolean("is_on_break", isOnBreak)
            putInt("total_seconds", totalSeconds)
            putString("task_title", taskTitle)
            apply()
        }
        
        // Widget'ı güncelle - PomodoroTimerWidgetProvider'a broadcast gönder
        val updateIntent = Intent(this, PomodoroTimerWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        }
        
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            ComponentName(this, PomodoroTimerWidgetProvider::class.java)
        )
        
        updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
        sendBroadcast(updateIntent)
    }

    private fun saveTimerState() {
        val prefs = getSharedPreferences("timer_state", Context.MODE_PRIVATE)
        prefs.edit().apply {
            putBoolean("is_running", isRunning)
            putInt("seconds_remaining", secondsRemaining)
            putInt("total_seconds", totalSeconds)
            putBoolean("is_on_break", isOnBreak)
            putString("task_title", taskTitle)
            putLong("last_update_time", System.currentTimeMillis())
            apply()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Pomodoro timer notifications"
                setSound(null, null)
                enableVibration(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "Farmodo::TimerWakeLock"
        ).apply {
            acquire(10*60*1000L /*10 minutes*/)
        }
    }

    private fun formatTime(seconds: Int): String {
        val minutes = seconds / 60
        val secs = seconds % 60
        return String.format("%02d:%02d", minutes, secs)
    }

    override fun onDestroy() {
        super.onDestroy()
        timer?.cancel()
        timer = null
        wakeLock?.release()
        mediaPlayer?.release()
        mediaPlayer = null
    }

    override fun onBind(intent: Intent?): IBinder? = null
}

