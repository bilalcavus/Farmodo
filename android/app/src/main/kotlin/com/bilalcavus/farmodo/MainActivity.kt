package com.bilalcavus.farmodo

import android.content.Intent
import android.os.Build
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.bilalcavus.farmodo/timer"
    private var wakeLock: PowerManager.WakeLock? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startTimerService" -> {
                    val secondsRemaining = call.argument<Int>("secondsRemaining") ?: 0
                    val totalSeconds = call.argument<Int>("totalSeconds") ?: 0
                    val isOnBreak = call.argument<Boolean>("isOnBreak") ?: false
                    val taskTitle = call.argument<String>("taskTitle") ?: "No active task"
                    
                    startTimerService(secondsRemaining, totalSeconds, isOnBreak, taskTitle)
                    result.success(true)
                }
                "pauseTimerService" -> {
                    pauseTimerService()
                    result.success(true)
                }
                "resumeTimerService" -> {
                    resumeTimerService()
                    result.success(true)
                }
                "stopTimerService" -> {
                    stopTimerService()
                    result.success(true)
                }
                "acquireWakeLock" -> {
                    val acquired = acquireWakeLock()
                    result.success(acquired)
                }
                "releaseWakeLock" -> {
                    releaseWakeLock()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun startTimerService(
        secondsRemaining: Int,
        totalSeconds: Int,
        isOnBreak: Boolean,
        taskTitle: String
    ) {
        try {
            val intent = Intent(this, TimerService::class.java).apply {
                action = TimerService.ACTION_START_TIMER
                putExtra(TimerService.EXTRA_SECONDS_REMAINING, secondsRemaining)
                putExtra(TimerService.EXTRA_TOTAL_SECONDS, totalSeconds)
                putExtra(TimerService.EXTRA_IS_ON_BREAK, isOnBreak)
                putExtra(TimerService.EXTRA_TASK_TITLE, taskTitle)
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                try {
                    startForegroundService(intent)
                } catch (e: Exception) {
                    // Android 12+ için fallback: Normal service olarak başlat
                    android.util.Log.w("MainActivity", "Cannot start foreground service, starting as normal service: ${e.message}")
                    startService(intent)
                }
            } else {
                startService(intent)
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error starting timer service: ${e.message}")
        }
    }
    
    private fun pauseTimerService() {
        val intent = Intent(this, TimerService::class.java).apply {
            action = TimerService.ACTION_PAUSE_TIMER
        }
        startService(intent)
    }
    
    private fun resumeTimerService() {
        val intent = Intent(this, TimerService::class.java).apply {
            action = TimerService.ACTION_RESUME_TIMER
        }
        startService(intent)
    }

    private fun stopTimerService() {
        val intent = Intent(this, TimerService::class.java).apply {
            action = TimerService.ACTION_STOP_TIMER
        }
        startService(intent)
    }

    private fun acquireWakeLock(): Boolean {
        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        if (wakeLock == null) {
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "Farmodo::TimerWakeLock"
            ).apply {
                setReferenceCounted(false)
            }
        }

        if (wakeLock?.isHeld != true) {
            wakeLock?.acquire()
        }

        return wakeLock?.isHeld == true
    }

    private fun releaseWakeLock() {
        if (wakeLock?.isHeld == true) {
            wakeLock?.release()
        }
    }

    override fun onDestroy() {
        releaseWakeLock()
        super.onDestroy()
    }
}
