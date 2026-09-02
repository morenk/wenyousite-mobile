package site.wenyou.app

import android.Manifest
import android.app.Activity
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.Executors

class ImageGalleryChannel(private val activity: Activity) {
    private companion object {
        const val CHANNEL = "site.wenyou.app/image_gallery"
        const val WRITE_PERMISSION_REQUEST = 4172
        const val MAXIMUM_BYTES = 10L * 1024L * 1024L
    }

    private val executor = Executors.newSingleThreadExecutor()
    private var channel: MethodChannel? = null
    private var pendingPermissionResult: MethodChannel.Result? = null

    fun register(engine: FlutterEngine) {
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(::handleCall)
        }
    }

    fun dispose() {
        channel?.setMethodCallHandler(null)
        channel = null
        pendingPermissionResult?.error(
            "permission_denied",
            "照片保存权限请求已取消。",
            null,
        )
        pendingPermissionResult = null
        executor.shutdownNow()
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != WRITE_PERMISSION_REQUEST) return false
        val result = pendingPermissionResult ?: return true
        pendingPermissionResult = null
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        if (granted) {
            result.success("granted")
        } else {
            val permanentlyDenied =
                !ActivityCompat.shouldShowRequestPermissionRationale(
                    activity,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE,
                )
            result.success(if (permanentlyDenied) "settingsRequired" else "denied")
        }
        return true
    }

    private fun handleCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestAddPermission" -> requestAddPermission(result)
            "saveImage" -> saveImage(call, result)
            "openSettings" -> openSettings(result)
            else -> result.notImplemented()
        }
    }

    private fun requestAddPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            result.success("granted")
            return
        }
        if (
            ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            result.success("granted")
            return
        }
        if (pendingPermissionResult != null) {
            result.error("permission_denied", "照片保存权限请求正在进行。", null)
            return
        }
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
            WRITE_PERMISSION_REQUEST,
        )
    }

    private fun saveImage(call: MethodCall, result: MethodChannel.Result) {
        val source = validatedSource(
            call.argument<String>("filePath"),
            call.argument<String>("fileName"),
            call.argument<String>("mimeType"),
        )
        if (source == null) {
            result.error("unsupported_format", "图片文件无效。", null)
            return
        }
        executor.execute {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    saveWithMediaStore(source)
                    activity.runOnUiThread { result.success(null) }
                } else {
                    saveLegacy(source, result)
                }
            } catch (error: Exception) {
                activity.runOnUiThread {
                    result.error(
                        "save_failed",
                        "图片未能写入系统相册。",
                        error.javaClass.simpleName,
                    )
                }
            }
        }
    }

    private fun validatedSource(
        filePath: String?,
        fileName: String?,
        mimeType: String?,
    ): ImageSource? {
        if (
            filePath.isNullOrBlank() ||
            fileName.isNullOrBlank() ||
            mimeType.isNullOrBlank() ||
            !fileName.matches(Regex("[A-Za-z0-9._-]{1,160}"))
        ) return null
        val extension = fileName.substringAfterLast('.', "").lowercase()
        val expectedMime =
            when (extension) {
                "jpg", "jpeg" -> "image/jpeg"
                "png" -> "image/png"
                "gif" -> "image/gif"
                "webp" -> "image/webp"
                "avif" -> "image/avif"
                else -> return null
            }
        if (mimeType != expectedMime) return null
        val allowedDirectory = File(activity.cacheDir, "wenyou_gallery").canonicalFile
        val file = File(filePath).canonicalFile
        val insideAllowedDirectory =
            file.path.startsWith("${allowedDirectory.path}${File.separator}")
        if (
            !insideAllowedDirectory ||
            !file.isFile ||
            file.length() <= 0L ||
            file.length() > MAXIMUM_BYTES
        ) return null
        return ImageSource(file, fileName, mimeType)
    }

    private fun saveWithMediaStore(source: ImageSource) {
        val values =
            ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, source.fileName)
                put(MediaStore.Images.Media.MIME_TYPE, source.mimeType)
                put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES)
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
        val resolver = activity.contentResolver
        val uri =
            resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("MediaStore insert failed")
        try {
            resolver.openOutputStream(uri, "w").use { output ->
                requireNotNull(output) { "MediaStore output unavailable" }
                source.file.inputStream().use { input -> input.copyTo(output) }
            }
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            if (resolver.update(uri, values, null, null) != 1) {
                throw IllegalStateException("MediaStore publish failed")
            }
        } catch (error: Exception) {
            resolver.delete(uri, null, null)
            throw error
        }
    }

    @Suppress("DEPRECATION")
    private fun saveLegacy(source: ImageSource, result: MethodChannel.Result) {
        val pictures =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
        if ((!pictures.exists() && !pictures.mkdirs()) || !pictures.isDirectory) {
            throw IllegalStateException("Pictures directory unavailable")
        }
        val destination = uniqueDestination(pictures, source.fileName)
        val partial = File(pictures, ".${destination.name}.part")
        try {
            source.file.inputStream().use { input ->
                FileOutputStream(partial).use { output ->
                    input.copyTo(output)
                    output.fd.sync()
                }
            }
            if (!partial.renameTo(destination)) {
                throw IllegalStateException("Image publish failed")
            }
        } catch (error: Exception) {
            partial.delete()
            destination.delete()
            throw error
        }
        MediaScannerConnection.scanFile(
            activity,
            arrayOf(destination.path),
            arrayOf(source.mimeType),
        ) { _, scannedUri ->
            activity.runOnUiThread {
                if (scannedUri == null) {
                    destination.delete()
                    result.error("save_failed", "图片未能加入系统相册。", null)
                } else {
                    result.success(null)
                }
            }
        }
    }

    private fun uniqueDestination(directory: File, requestedName: String): File {
        val first = File(directory, requestedName)
        if (!first.exists()) return first
        val base = requestedName.substringBeforeLast('.')
        val extension = requestedName.substringAfterLast('.')
        for (index in 1..999) {
            val candidate = File(directory, "${base}_$index.$extension")
            if (!candidate.exists()) return candidate
        }
        throw IllegalStateException("No available image name")
    }

    private fun openSettings(result: MethodChannel.Result) {
        try {
            activity.startActivity(
                Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.parse("package:${activity.packageName}"),
                ),
            )
            result.success(null)
        } catch (error: Exception) {
            result.error("settings_unavailable", "系统设置无法打开。", null)
        }
    }

    private data class ImageSource(
        val file: File,
        val fileName: String,
        val mimeType: String,
    )
}
