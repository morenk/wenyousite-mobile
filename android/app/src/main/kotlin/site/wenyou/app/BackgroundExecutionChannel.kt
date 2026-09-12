package site.wenyou.app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class BackgroundExecutionChannel(private val activity: MainActivity) {
    private var channel: MethodChannel? = null
    private var resumed = false

    fun register(engine: FlutterEngine) {
        channel = MethodChannel(
            engine.dartExecutor.binaryMessenger,
            "site.wenyou.app/background_execution",
        ).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "setEnabled" -> {
                            BackgroundReminderServiceState.enabled = call.argument<Boolean>("enabled") == true
                            if (!BackgroundReminderServiceState.enabled) stop()
                            result.success(null)
                        }
                        "start" -> {
                            // onPause 在失去前台启动资格之前已发出原生启动请求。
                            // 迟到的 Dart 回调只查询该请求，不从后台重新启动服务。
                            if (resumed) startBeforePause()
                            result.success(BackgroundReminderServiceState.status)
                        }
                        "stop" -> {
                            stop()
                            result.success(null)
                        }
                        "getStatus" -> {
                            BackgroundReminderServiceState.service?.checkNotificationAccess()
                            result.success(BackgroundReminderServiceState.status)
                        }
                        "openNotificationSettings" -> {
                            openNotificationSettings()
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("background_execution_failed", "后台消息提醒操作失败。", error.javaClass.simpleName)
                }
            }
        }
        BackgroundReminderServiceState.onStatusChanged = { status ->
            channel?.invokeMethod("statusChanged", status)
        }
    }

    fun onResume() {
        resumed = true
        stop("foreground")
    }

    fun onPause() {
        // 必须在 Activity.super.onPause() 前执行，不能等后台 Dart Timer。
        startBeforePause()
        resumed = false
    }

    private fun startBeforePause() {
        val state = BackgroundReminderServiceState
        if (!state.enabled || state.backgroundRequested) return
        try {
            if (!WenyouBackgroundReminderService.canNotify(activity)) {
                state.publish("blocked")
                return
            }
            state.backgroundRequested = true
            state.publish("starting")
            activity.startForegroundService(
                Intent(activity, WenyouBackgroundReminderService::class.java)
                    .putExtra("generation", state.generation),
            )
        } catch (_: Exception) {
            state.backgroundRequested = false
            state.publish("failed")
        }
    }

    private fun stop(status: String = "stopped") {
        val state = BackgroundReminderServiceState
        state.generation++
        state.backgroundRequested = false
        state.service?.stopReminder()
        activity.stopService(Intent(activity, WenyouBackgroundReminderService::class.java))
        state.publish(status)
    }

    private fun openNotificationSettings() {
        try {
            activity.startActivity(
                Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
                    .putExtra(Settings.EXTRA_CHANNEL_ID, WenyouBackgroundReminderService.MESSAGE_CHANNEL_ID),
            )
        } catch (_: ActivityNotFoundException) {
            activity.startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${activity.packageName}")),
            )
        }
    }

    fun dispose() {
        BackgroundReminderServiceState.enabled = false
        stop()
        BackgroundReminderServiceState.onStatusChanged = null
        channel?.setMethodCallHandler(null)
        channel = null
    }
}

// 只保存当前进程的执行状态，不持有 Token 或用户信息，不支持进程/开机恢复。
internal object BackgroundReminderServiceState {
    var enabled = false
    var backgroundRequested = false
    var generation = 0
    var status = "stopped"
        private set
    var service: WenyouBackgroundReminderService? = null
    var onStatusChanged: ((String) -> Unit)? = null

    fun publish(value: String) {
        if (status == value) return
        status = value
        onStatusChanged?.invoke(value)
    }
}
