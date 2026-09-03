package site.wenyou.app

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class DocumentSaverChannel(private val activity: FlutterActivity) {
    private companion object {
        const val CHANNEL = "site.wenyou.app/document_saver"
        const val REQUEST_CREATE_DOCUMENT = 6204
        const val ZIP_MIME_TYPE = "application/zip"
    }

    private data class PendingSave(
        val source: File,
        val result: MethodChannel.Result,
    )

    private var channel: MethodChannel? = null
    private var pendingSave: PendingSave? = null

    fun register(engine: FlutterEngine) {
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(::handleCall)
        }
    }

    fun dispose() {
        channel?.setMethodCallHandler(null)
        channel = null
        pendingSave?.result?.error("engine_closed", "档案保存已中断。", null)
        pendingSave = null
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CREATE_DOCUMENT) return false
        val pending = pendingSave ?: return true
        pendingSave = null
        if (resultCode != Activity.RESULT_OK) {
            pending.result.success(false)
            return true
        }
        val uri = data?.data
        if (uri == null) {
            pending.result.error("missing_destination", "系统没有返回保存位置。", null)
            return true
        }
        try {
            activity.contentResolver.openOutputStream(uri, "w").use { output ->
                requireNotNull(output) { "Document output unavailable" }
                pending.source.inputStream().use { input -> input.copyTo(output) }
            }
            pending.result.success(true)
        } catch (error: Exception) {
            pending.result.error("save_failed", "档案没有保存成功。", error.javaClass.simpleName)
        }
        return true
    }

    private fun handleCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "saveDocument") {
            result.notImplemented()
            return
        }
        if (pendingSave != null) {
            result.error("save_in_progress", "已有档案正在等待保存。", null)
            return
        }
        val filePath = call.argument<String>("filePath")
        val fileName = call.argument<String>("fileName")
        val mimeType = call.argument<String>("mimeType")
        if (filePath.isNullOrBlank() || fileName.isNullOrBlank() || mimeType != ZIP_MIME_TYPE) {
            result.error("invalid_document", "档案参数无效。", null)
            return
        }
        try {
            val allowedDirectory = activity.cacheDir.canonicalFile
            val source = File(filePath).canonicalFile
            val isInsideCache = source.path.startsWith("${allowedDirectory.path}${File.separator}")
            val safeFileName = File(fileName).name == fileName && fileName.endsWith(".zip", true)
            if (!isInsideCache || !source.isFile || source.extension.lowercase() != "zip" || !safeFileName) {
                result.error("invalid_document", "档案参数无效。", null)
                return
            }
            pendingSave = PendingSave(source, result)
            activity.startActivityForResult(
                Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = ZIP_MIME_TYPE
                    putExtra(Intent.EXTRA_TITLE, fileName)
                },
                REQUEST_CREATE_DOCUMENT,
            )
        } catch (error: Exception) {
            pendingSave = null
            result.error("picker_failed", "无法打开系统文件保存器。", error.javaClass.simpleName)
        }
    }
}
