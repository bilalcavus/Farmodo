package com.bilalcavus.farmodo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PomodoroTimerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.pomodoro_timer_widget).apply {
                // Widget verilerini al
                val widgetData = HomeWidgetPlugin.getData(context)
                
                val isRunning = widgetData.getBoolean("timer_running", false)
                val secondsRemaining = widgetData.getInt("seconds_remaining", 0)
                val isOnBreak = widgetData.getBoolean("is_on_break", false)
                val totalSeconds = widgetData.getInt("total_seconds", 0)
                val taskTitle = widgetData.getString("task_title", "No active task")
                
                // Timer metnini güncelle
                val timeText = formatTime(secondsRemaining)
                setTextViewText(R.id.timer_text, timeText)
                
                // Görev başlığını güncelle
                setTextViewText(R.id.task_title, taskTitle)
                
                // Durum metnini güncelle
                val statusText = if (isOnBreak) "BREAK" else "FOCUS"
                setTextViewText(R.id.status_text, statusText)
                
                // İlerleme çubuğunu güncelle
                val progress = if (totalSeconds > 0) {
                    ((totalSeconds - secondsRemaining) * 100 / totalSeconds).toInt()
                } else {
                    0
                }
                setProgressBar(R.id.progress_circle, 100, progress, false)
                
                // Play/Pause butonunu güncelle
                val buttonIcon = if (isRunning) R.drawable.ic_pause else R.drawable.ic_play
                setImageViewResource(R.id.play_pause_button, buttonIcon)
                
                // Buton tıklama olayını ayarla
                val buttonIntent = Intent(context, PomodoroTimerWidgetProvider::class.java).apply {
                    action = if (isRunning) "PAUSE_TIMER" else "RESUME_TIMER"
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                }
                val buttonPendingIntent = PendingIntent.getBroadcast(
                    context,
                    widgetId,
                    buttonIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.play_pause_button, buttonPendingIntent)
                
                // Widget'a tıklama olayını ayarla (uygulamayı aç)
                val appIntent = Intent(context, MainActivity::class.java)
                val appPendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    appIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.timer_text, appPendingIntent)
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        when (intent.action) {
            "START_TIMER", "RESUME_TIMER" -> {
                // Timer service'i başlat veya devam ettir
                val widgetData = HomeWidgetPlugin.getData(context)
                val secondsRemaining = widgetData.getInt("seconds_remaining", 0)
                val totalSeconds = widgetData.getInt("total_seconds", 0)
                val isOnBreak = widgetData.getBoolean("is_on_break", false)
                val taskTitle = widgetData.getString("task_title", "No active task") ?: "No active task"
                
                if (secondsRemaining > 0) {
                    val serviceIntent = Intent(context, TimerService::class.java).apply {
                        action = TimerService.ACTION_RESUME_TIMER
                        putExtra(TimerService.EXTRA_SECONDS_REMAINING, secondsRemaining)
                        putExtra(TimerService.EXTRA_TOTAL_SECONDS, totalSeconds)
                        putExtra(TimerService.EXTRA_IS_ON_BREAK, isOnBreak)
                        putExtra(TimerService.EXTRA_TASK_TITLE, taskTitle)
                    }
                    
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                }
                
                widgetData.edit().putBoolean("timer_running", true).apply()
                updateWidget(context)
            }
            "PAUSE_TIMER" -> {
                // Timer service'i duraklat
                val serviceIntent = Intent(context, TimerService::class.java).apply {
                    action = TimerService.ACTION_PAUSE_TIMER
                }
                context.startService(serviceIntent)
                
                val widgetData = HomeWidgetPlugin.getData(context)
                widgetData.edit().putBoolean("timer_running", false).apply()
                updateWidget(context)
            }
        }
    }
    
    private fun updateWidget(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            ComponentName(context, PomodoroTimerWidgetProvider::class.java)
        )
        onUpdate(context, appWidgetManager, appWidgetIds)
    }
    
    private fun formatTime(seconds: Int): String {
        val minutes = seconds / 60
        val secs = seconds % 60
        return String.format("%02d:%02d", minutes, secs)
    }
}
