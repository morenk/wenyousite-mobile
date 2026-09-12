package site.wenyou.app

import android.app.Activity
import android.content.ClipboardManager
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class ClipboardNavigationChannel(private val activity: Activity) {
    private companion object {
        const val CHANNEL = "site.wenyou.app/clipboard_navigation"
    }

    private var channel: MethodChannel? = null

    fun register(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "getChangeToken" -> result.success(readChangeToken())
                        "readSnapshot" -> result.success(readSnapshot())
                        else -> result.notImplemented()
                    }
                } catch (_: SecurityException) {
                    result.error(
                        "clipboard_unavailable",
                        "暂时无法读取剪贴板。",
                        null,
                    )
                }
            }
        }
    }

    fun dispose() {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    private fun clipboard(): ClipboardManager {
        return activity.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    }

    private fun readChangeToken(): String? {
        val timestamp = clipboard().primaryClipDescription?.timestamp ?: 0L
        return if (timestamp > 0L) "android:$timestamp" else null
    }

    private fun readSnapshot(): Map<String, String>? {
        val clip = clipboard().primaryClip ?: return null
        if (clip.itemCount < 1) return null
        val text = clip.getItemAt(0).text?.toString() ?: return null
        val timestamp = clip.description.timestamp
        val snapshot = mutableMapOf("text" to text)
        if (timestamp > 0L) snapshot["changeToken"] = "android:$timestamp"
        return snapshot
    }
}
