package site.wenyou.app

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.os.PersistableBundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class EditorClipboardChannel(private val context: Context) {
    private companion object {
        const val CHANNEL = "site.wenyou.app/editor_clipboard"
        const val MARKER_KEY = "site.wenyou.app.editor_clipboard.marker"
    }

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "readText" -> result.success(readText())
                        "writeText" -> {
                            val text = call.argument<String>("text")
                            val marker = call.argument<String>("marker")
                            if (text == null || marker.isNullOrBlank()) {
                                result.error("invalid_clipboard_data", "剪贴板内容无效。", null)
                            } else {
                                writeText(text, marker)
                                result.success(null)
                            }
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: SecurityException) {
                    result.error("clipboard_denied", "无法访问剪贴板。", error.javaClass.simpleName)
                } catch (error: RuntimeException) {
                    result.error("clipboard_failed", "无法访问剪贴板。", error.javaClass.simpleName)
                }
            }
    }

    private fun readText(): Map<String, String?> {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val description = clipboard.primaryClipDescription
        val clip = clipboard.primaryClip
        if (description == null || clip == null || !description.hasMimeType("text/*")) {
            return mapOf("text" to null, "marker" to null)
        }

        val values = buildList {
            for (index in 0 until clip.itemCount) {
                val value = clip.getItemAt(index).coerceToText(context)?.toString()
                if (value != null) add(value)
            }
        }
        return mapOf(
            "text" to values.takeIf { it.isNotEmpty() }?.joinToString("\n"),
            "html" to readSingleHtmlItem(clip, description),
            "marker" to description.extras?.getString(MARKER_KEY),
        )
    }

    private fun readSingleHtmlItem(
        clip: ClipData,
        description: ClipDescription,
    ): String? {
        if (!description.hasMimeType(ClipDescription.MIMETYPE_TEXT_HTML)) return null
        val values = buildList {
            for (index in 0 until clip.itemCount) {
                clip.getItemAt(index).htmlText?.let(::add)
            }
        }
        return values.singleOrNull()
    }

    private fun writeText(text: String, marker: String) {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("text", text)
        clip.description.extras = PersistableBundle().apply {
            putString(MARKER_KEY, marker)
        }
        clipboard.setPrimaryClip(clip)
    }
}
