package site.wenyou.app

import android.app.Activity
import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.os.PersistableBundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class ClipboardNavigationChannel(private val activity: Activity) {
    private companion object {
        const val CHANNEL = "site.wenyou.app/clipboard_navigation"
        const val COPY_MARKER = "site.wenyou.app.navigation_copy"
        val COPY_MARKER_PATTERN = Regex("^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$")
    }

    private var channel: MethodChannel? = null

    fun register(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "getChangeToken" -> result.success(readChangeToken())
                        "readSnapshot" -> result.success(readSnapshot())
                        "writeText" -> {
                            val text = call.argument<String>("text")
                            if (text == null) {
                                result.error("invalid_text", "复制内容不可用。", null)
                            } else {
                                result.success(writeText(text))
                            }
                        }
                        else -> result.notImplemented()
                    }
                } catch (_: SecurityException) {
                    result.error(
                        "clipboard_unavailable",
                        "暂时无法使用剪贴板。",
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
        return clipboard().primaryClipDescription?.let(::changeToken)
    }

    private fun changeToken(description: ClipDescription): String? {
        val timestamp = description.timestamp
        if (timestamp <= 0L) return null
        val marker = description.extras?.getString(COPY_MARKER)?.takeIf {
            COPY_MARKER_PATTERN.matches(it)
        }
        return if (marker == null) "android:$timestamp" else "android:$timestamp:$marker"
    }

    private fun writeText(text: String): String? {
        val marker = UUID.randomUUID().toString()
        val clip = ClipData.newPlainText("", text)
        clip.description.extras = PersistableBundle().apply { putString(COPY_MARKER, marker) }
        val manager = clipboard()
        manager.setPrimaryClip(clip)
        // 只认领刚写入的事件；暂不可读时保留随机收据，首次回读再绑定系统版本。
        val description = try { manager.primaryClipDescription } catch (_: SecurityException) { null }
        return if (description?.extras?.getString(COPY_MARKER) == marker) {
            changeToken(description) ?: "android:own:$marker"
        } else "android:own:$marker"
    }

    private fun readSnapshot(): Map<String, String>? {
        val clip = clipboard().primaryClip ?: return null
        if (clip.itemCount < 1) return null
        val text = clip.getItemAt(0).text?.toString() ?: return null
        val snapshot = mutableMapOf("text" to text)
        changeToken(clip.description)?.let { snapshot["changeToken"] = it }
        return snapshot
    }
}
