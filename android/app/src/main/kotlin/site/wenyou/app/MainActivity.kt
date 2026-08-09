package site.wenyou.app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private companion object {
        const val UPDATE_CHANNEL = "site.wenyou.app/app_update"
        const val APK_MIME_TYPE = "application/vnd.android.package-archive"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UPDATE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledAppInfo" -> {
                        val packageInfo = packageManager.getPackageInfo(packageName, 0)
                        @Suppress("DEPRECATION")
                        val buildNumber =
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                packageInfo.longVersionCode
                            } else {
                                packageInfo.versionCode.toLong()
                            }
                        result.success(
                            mapOf(
                                "version" to (packageInfo.versionName ?: "unknown"),
                                "build" to buildNumber.toString(),
                            ),
                        )
                    }
                    "installApk" -> {
                        val filePath = call.argument<String>("filePath")
                        if (filePath.isNullOrBlank()) {
                            result.error("invalid_path", "安装包路径为空。", null)
                            return@setMethodCallHandler
                        }
                        installApk(filePath, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun installApk(filePath: String, result: MethodChannel.Result) {
        try {
            val allowedDirectory = File(cacheDir, "wenyou_updates").canonicalFile
            val apk = File(filePath).canonicalFile
            val isInsideAllowedDirectory =
                apk.path.startsWith("${allowedDirectory.path}${File.separator}")
            if (!isInsideAllowedDirectory || !apk.isFile || apk.extension.lowercase() != "apk") {
                result.error("invalid_path", "安装包路径无效。", null)
                return
            }

            if (!packageManager.canRequestPackageInstalls()) {
                startActivity(
                    Intent(
                        Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.parse("package:$packageName"),
                    ),
                )
                result.success("permissionRequired")
                return
            }

            val contentUri = FileProvider.getUriForFile(
                this,
                "$packageName.fileprovider",
                apk,
            )
            val installIntent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(contentUri, APK_MIME_TYPE)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(installIntent)
            result.success("installerOpened")
        } catch (error: Exception) {
            result.error("installer_failed", "无法打开系统安装器。", error.javaClass.simpleName)
        }
    }
}
