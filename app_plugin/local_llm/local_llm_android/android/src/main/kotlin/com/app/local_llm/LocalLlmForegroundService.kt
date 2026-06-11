package com.app.local_llm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

class LocalLlmForegroundService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stop()
            return START_NOT_STICKY
        }

        val title = intent?.getStringExtra(EXTRA_TITLE) ?: "Local LLM"
        val message = intent?.getStringExtra(EXTRA_MESSAGE) ?: "Local model is running."
        startForeground(title, message)
        isRunning = true
        return START_STICKY
    }

    override fun onDestroy() {
        stopForegroundCompat()
        isRunning = false
        super.onDestroy()
    }

    private fun startForeground(title: String, message: String) {
        ensureNotificationChannel()
        val notification = buildNotification(title, message)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun buildNotification(title: String, message: String): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = launchIntent?.let {
            PendingIntent.getActivity(
                this,
                0,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
        val icon = applicationInfo.icon.takeIf { it != 0 } ?: android.R.drawable.stat_sys_warning

        builder
            .setSmallIcon(icon)
            .setContentTitle(title)
            .setContentText(message)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            builder.setCategory(Notification.CATEGORY_SERVICE)
        }
        if (pendingIntent != null) {
            builder.setContentIntent(pendingIntent)
        }
        return builder.build()
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Local LLM",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Keeps local on-device inference visible while the model is loaded."
            setShowBadge(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun stop() {
        stopForegroundCompat()
        isRunning = false
        stopSelf()
    }

    private fun stopForegroundCompat() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }

    companion object {
        private const val ACTION_START = "com.app.local_llm.START"
        private const val ACTION_STOP = "com.app.local_llm.STOP"
        private const val CHANNEL_ID = "app_local_llm_service"
        private const val EXTRA_MESSAGE = "message"
        private const val EXTRA_TITLE = "title"
        private const val NOTIFICATION_ID = 3301

        @Volatile
        var isRunning: Boolean = false
            private set

        fun start(context: Context, title: String, message: String) {
            val intent = Intent(context, LocalLlmForegroundService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_MESSAGE, message)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, LocalLlmForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            context.stopService(intent)
            isRunning = false
        }
    }
}
