package site.wenyou.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat

class WenyouBackgroundReminderService : Service() {
    companion object {
        const val MESSAGE_CHANNEL_ID = "wenyou_messages_v1"
        const val SERVICE_CHANNEL_ID = "wenyou_background_reminders_v1"
        const val NOTIFICATION_ID = 1001

        fun canNotify(context: Context): Boolean {
            val manager = context.getSystemService(NotificationManager::class.java)
            // 重复创建同一 ID 保留用户对重要性、声音和振动的选择。
            manager.createNotificationChannel(
                NotificationChannel(SERVICE_CHANNEL_ID, "后台消息提醒", NotificationManager.IMPORTANCE_LOW).apply {
                    description = "离开温油站后定期检查新消息"
                    setSound(null, null)
                    enableVibration(false)
                    setShowBadge(false)
                },
            )
            if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return false
            return listOf(MESSAGE_CHANNEL_ID, SERVICE_CHANNEL_ID).all { id ->
                val channel = manager.getNotificationChannel(id)
                channel != null && channel.importance != NotificationManager.IMPORTANCE_NONE &&
                    (Build.VERSION.SDK_INT < 28 || channel.group == null ||
                        manager.getNotificationChannelGroup(channel.group)?.isBlocked != true)
            }
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var running = false
    private var runGeneration = -1
    private val permissionCheck = object : Runnable {
        override fun run() {
            checkNotificationAccess()
            if (running) handler.postDelayed(this, 30_000)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val state = BackgroundReminderServiceState
        if (intent == null || !state.enabled || !state.backgroundRequested ||
            intent.getIntExtra("generation", -1) != state.generation
        ) {
            stopSelf(startId)
            return START_NOT_STICKY
        }
        try {
            if (!canNotify(this)) {
                state.backgroundRequested = false
                state.publish("blocked")
                stopSelf(startId)
                return START_NOT_STICKY
            }
            val launchIntent = Intent(this, MainActivity::class.java).apply {
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
                this.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            val notification = NotificationCompat.Builder(this, SERVICE_CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_stat_wenyou)
                .setContentTitle("后台消息提醒已开启")
                .setContentText("温油站会定期检查新消息")
                .setContentIntent(PendingIntent.getActivity(
                    this, NOTIFICATION_ID, launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ))
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                .setOngoing(true)
                .setSilent(true)
                .setOnlyAlertOnce(true)
                .setShowWhen(false)
                .build()
            ServiceCompat.startForeground(
                this, NOTIFICATION_ID, notification,
                if (Build.VERSION.SDK_INT >= 34) ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE else 0,
            )
            state.service = this
            runGeneration = state.generation
            running = true
            state.publish("running")
            handler.removeCallbacks(permissionCheck)
            handler.postDelayed(permissionCheck, 30_000)
        } catch (_: Exception) {
            state.backgroundRequested = false
            state.publish("failed")
            stopReminder()
        }
        return START_NOT_STICKY
    }

    fun checkNotificationAccess() {
        if (!running) return
        try {
            if (canNotify(this)) return
            BackgroundReminderServiceState.publish("blocked")
        } catch (_: Exception) {
            BackgroundReminderServiceState.publish("failed")
        }
        BackgroundReminderServiceState.backgroundRequested = false
        stopReminder()
    }

    fun stopReminder() {
        running = false
        handler.removeCallbacks(permissionCheck)
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        running = false
        handler.removeCallbacks(permissionCheck)
        val state = BackgroundReminderServiceState
        if (state.service === this) {
            state.service = null
            // 快速回前台再切后台时，旧服务的销毁不能撤销下一代启动请求。
            if (state.generation == runGeneration) {
                state.backgroundRequested = false
                if (state.status == "running" || state.status == "starting") state.publish("stopped")
            }
        }
        super.onDestroy()
    }
}
