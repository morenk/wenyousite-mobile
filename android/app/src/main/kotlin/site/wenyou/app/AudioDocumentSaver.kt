package site.wenyou.app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.io.Closeable
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

/** 音频使用独立请求与后台流复制，不改变既有 ZIP 保存行为。 */
class AudioDocumentSaver(private val activity: FlutterActivity) {
    private companion object {
        const val REQUEST = 6205
        const val MAX_BYTES = 30L * 1024 * 1024
    }
    private class Pending(val id: String, val source: File, val result: MethodChannel.Result) {
        val cancelled = AtomicBoolean(false)
        @Volatile var input: Closeable? = null
        @Volatile var output: Closeable? = null
        var copying = false
    }
    private val worker = Executors.newSingleThreadExecutor()
    private val canceller = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var pending: Pending? = null
    private var disposed = false

    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        if (call.method == "cancelAudio") {
            pending?.takeIf { it.id == call.argument<String>("id") }?.let(::cancel)
            result.success(null)
            return true
        }
        if (call.method != "saveAudio") return false
        if (pending != null || disposed) {
            result.error("save_in_progress", "已有音频正在等待保存。", null)
            return true
        }
        try {
            val id = requireNotNull(call.argument<String>("id"))
            val source = File(requireNotNull(call.argument<String>("filePath"))).canonicalFile
            val name = requireNotNull(call.argument<String>("fileName"))
            require(call.argument<String>("mimeType") == "audio/mpeg")
            require(source.path.startsWith(activity.cacheDir.canonicalPath + File.separator))
            require(source.isFile && source.length() in 1..MAX_BYTES && source.extension.equals("mp3", true))
            require(File(name).name == name && name.endsWith(".mp3", true))
            pending = Pending(id, source, result)
            activity.startActivityForResult(Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "audio/mpeg"
                putExtra(Intent.EXTRA_TITLE, name)
            }, REQUEST)
        } catch (_: Exception) {
            pending = null
            result.error("save_failed", "无法打开系统文件保存器。", null)
        }
        return true
    }

    fun onActivityResult(code: Int, resultCode: Int, data: Intent?): Boolean {
        if (code != REQUEST) return false
        val item = pending ?: return true
        val destination = data?.data
        if (resultCode != Activity.RESULT_OK || destination == null) {
            finish(item, false, null)
            return true
        }
        item.copying = true
        worker.execute {
            var failure: Exception? = null
            var saved = false
            try {
                if (item.cancelled.get()) throw IOException("cancelled")
                activity.contentResolver.openOutputStream(destination, "w").use { output ->
                    requireNotNull(output)
                    item.output = output
                    item.source.inputStream().use { input ->
                        item.input = input
                        val count = BoundedAudioCopy.copy(input, output, MAX_BYTES) { item.cancelled.get() }
                        if (count != item.source.length() || item.cancelled.get()) throw IOException("incomplete")
                    }
                }
                saved = !item.cancelled.get()
            } catch (error: Exception) {
                failure = error
            } finally {
                item.input = null
                item.output = null
            }
            if (!saved) removePartial(destination)
            main.post { finish(item, saved, failure, destination) }
        }
        return true
    }

    private fun cancel(item: Pending) {
        item.cancelled.set(true)
        // 关闭阻塞的 provider 流也不占主线程；工作线程负责目标清理与最终回调。
        canceller.execute {
            try { item.input?.close() } catch (_: Exception) { }
            try { item.output?.close() } catch (_: Exception) { }
        }
    }

    private fun removePartial(uri: Uri) {
        try {
            if (!DocumentsContract.deleteDocument(activity.contentResolver, uri)) throw IOException("cleanup_failed")
        } catch (_: Exception) {
            // 部分 provider 不支持删除；尽量截断，避免留下可误认为完整的音频。
            try {
                val output = activity.contentResolver.openOutputStream(uri, "wt")
                if (output == null) Log.w("AudioDocumentSaver", "audio_target_cleanup_failed")
                output?.close()
            } catch (_: Exception) { Log.w("AudioDocumentSaver", "audio_target_cleanup_failed") }
        }
    }

    private fun finish(item: Pending, saved: Boolean, failure: Exception?, destination: Uri? = null) {
        if (pending !== item) return
        // 复制完成到主线程回调之间发生取消，也要撤销自有导出目标。
        if (saved && item.cancelled.get() && destination != null) {
            worker.execute {
                removePartial(destination)
                main.post { finish(item, false, null) }
            }
            return
        }
        pending = null
        if (item.cancelled.get() || failure == null) item.result.success(saved && !item.cancelled.get())
        else item.result.error("save_failed", "音频没有保存成功。", null)
        if (disposed) { worker.shutdown(); canceller.shutdown() }
    }

    fun dispose() {
        disposed = true
        pending?.let(::cancel)
        // 正在复制时由工作线程清理目标后结束；选择器尚未返回则结束 Dart 等待。
        pending?.takeIf { !it.copying }?.let { finish(it, false, null) }
        if (pending == null) { worker.shutdown(); canceller.shutdown() }
    }
}
