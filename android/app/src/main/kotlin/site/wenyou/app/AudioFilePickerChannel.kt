package site.wenyou.app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.Closeable
import java.io.File
import java.io.IOException
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

/** SAF 只读取主动选择的文件；复制和取消清理均不占用主线程。 */
class AudioFilePickerChannel(private val activity: FlutterActivity) {
    private companion object {
        const val CHANNEL = "site.wenyou.app/audio_file_picker"
        const val FIRST_REQUEST_CODE = 6300
    }

    private class Selection(
        val id: String,
        val requestCode: Int,
        val maximumBytes: Long,
        val result: MethodChannel.Result,
    ) {
        val cancelled = AtomicBoolean(false)
        val cancellation = CancellationSignal()
        @Volatile var source: Closeable? = null
        var choosing = true
    }

    private val main = Handler(Looper.getMainLooper())
    private val worker = Executors.newSingleThreadExecutor()
    private val cleanup = Executors.newSingleThreadExecutor()
    private val completed = mutableMapOf<String, File>()
    private var channel: MethodChannel? = null
    private var pending: Selection? = null
    private var disposed = false
    private var nextRequestCode = FIRST_REQUEST_CODE
    private val launchedCodes = mutableSetOf<Int>()

    fun register(engine: FlutterEngine) {
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(::handle)
        }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pick" -> pick(call, result)
            "cancel" -> {
                pending?.takeIf { it.id == call.argument<String>("id") }?.let(::cancel)
                result.success(null)
            }
            "release" -> {
                val id = call.argument<String>("id")
                val file = completed.remove(id)
                cleanup.execute {
                    val deleted = file == null || !file.exists() || file.delete()
                    main.post {
                        if (deleted) result.success(null)
                        else {
                            if (!disposed && id != null && file != null) completed[id] = file
                            result.error("cleanup_failed", "临时文件清理失败。", null)
                        }
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun pick(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("id")
        val maximumBytes = call.argument<Number>("maximumBytes")?.toLong()
        val types = call.argument<List<String>>("contentTypes")
        if (disposed || pending != null) {
            result.error("picker_busy", "请先完成当前文件选择。", null)
            return
        }
        if (id.isNullOrBlank() || maximumBytes == null || maximumBytes <= 0 ||
            maximumBytes == Long.MAX_VALUE || types.isNullOrEmpty() ||
            types.any { !it.matches(Regex("(?:audio|video|application)/[a-zA-Z0-9.+-]+")) }) {
            result.error("invalid_request", "无法选择音频文件。", null)
            return
        }
        while (launchedCodes.contains(nextRequestCode)) nextRequestCode++
        if (nextRequestCode > 65535) {
            result.error("picker_busy", "请重新打开页面后选择音频。", null)
            return
        }
        val selection = Selection(id, nextRequestCode++, maximumBytes, result)
        pending = selection
        val retained = completed.values.map { it.name }.toSet()
        worker.execute { pruneExpiredSelections(retained) }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(Intent.EXTRA_MIME_TYPES, types.toTypedArray())
        }
        try {
            launchedCodes.add(selection.requestCode)
            activity.startActivityForResult(intent, selection.requestCode)
        } catch (_: RuntimeException) {
            launchedCodes.remove(selection.requestCode)
            pending = null
            result.error("picker_unavailable", "无法打开文件选择器。", null)
        }
    }

    /** 仅回收本通道的 UUID 缓存；detach 中断后的未领取副本最多保留一天。 */
    private fun pruneExpiredSelections(retained: Set<String>) {
        val directory = File(activity.cacheDir, "audio-selections-v1")
        val cutoff = System.currentTimeMillis() - 24 * 60 * 60 * 1000L
        directory.listFiles()?.forEach { file ->
            if (file.isFile && file.name !in retained && file.lastModified() < cutoff &&
                file.name.matches(Regex("[a-fA-F0-9-]{36}\\.[a-z0-9]{1,8}"))) {
                file.delete()
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (!launchedCodes.remove(requestCode)) return false
        val selection = pending?.takeIf { it.requestCode == requestCode } ?: return true
        selection.choosing = false
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            pending = null
            selection.result.success(null)
            return true
        }
        worker.execute { copy(selection, uri) }
        return true
    }

    private fun copy(selection: Selection, uri: Uri) {
        var destination: File? = null
        try {
            if (selection.cancelled.get()) throw AudioCopyCancelled()
            val resolver = activity.contentResolver
            var name = "音频"
            resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE), null, null, null,
                selection.cancellation)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (nameIndex >= 0) name = File(cursor.getString(nameIndex) ?: name).name.take(200)
                    val sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE)
                    if (sizeIndex >= 0 && !cursor.isNull(sizeIndex) && cursor.getLong(sizeIndex) > selection.maximumBytes) {
                        throw AudioCopyTooLarge()
                    }
                }
            }
            val contentType = resolver.getType(uri)
            val extension = name.substringAfterLast('.', "").lowercase()
                .takeIf { it.matches(Regex("[a-z0-9]{1,8}")) } ?: "audio"
            val directory = File(activity.cacheDir, "audio-selections-v1")
            if (!directory.isDirectory && !directory.mkdirs()) throw IOException()
            val file = File(directory, "${UUID.randomUUID()}.$extension")
            destination = file
            val descriptor = resolver.openAssetFileDescriptor(uri, "r", selection.cancellation)
                ?: throw IOException()
            val size = descriptor.use { asset ->
                asset.createInputStream().use { input ->
                    selection.source = input
                    file.outputStream().use { output ->
                        BoundedAudioCopy.copy(input, output, selection.maximumBytes) { selection.cancelled.get() }
                    }
                }
            }
            selection.source = null
            main.post {
                if (disposed || pending !== selection || selection.cancelled.get()) {
                    cleanup.execute { file.delete() }
                } else {
                    pending = null
                    completed[selection.id] = file
                    selection.result.success(mapOf(
                        "id" to selection.id, "path" to file.path, "filename" to name,
                        "size" to size, "contentType" to contentType,
                    ))
                }
            }
        } catch (error: Exception) {
            destination?.delete()
            selection.source = null
            main.post {
                if (pending !== selection || disposed) return@post
                pending = null
                when {
                    selection.cancelled.get() -> selection.result.success(null)
                    error is AudioCopyTooLarge -> selection.result.error("file_too_large", "音频文件过大。", null)
                    error is AudioCopyEmpty -> selection.result.error("file_empty", "音频文件为空。", null)
                    else -> selection.result.error("file_read_failed", "音频文件读取失败，请重新选择。", null)
                }
            }
        }
    }

    private fun cancel(selection: Selection) {
        selection.cancelled.set(true)
        pending = null
        if (selection.choosing) activity.finishActivity(selection.requestCode)
        cleanup.execute {
            selection.cancellation.cancel()
            try { selection.source?.close() } catch (_: IOException) { /* 复制线程负责最终清理。 */ }
        }
        selection.result.success(null)
    }

    fun dispose() {
        disposed = true
        channel?.setMethodCallHandler(null)
        channel = null
        pending?.let(::cancel)
        // 复制线程发出的主线程收尾先完成，之后再关闭清理队列。
        worker.execute { main.post { cleanup.shutdown() } }
        worker.shutdown()
        // 已完成句柄仍可能被 Dart 保存到草稿；缓存由系统回收，不删除用户源文件。
        completed.clear()
    }
}
