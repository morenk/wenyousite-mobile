package site.wenyou.app

import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import androidx.core.content.FileProvider
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private companion object {
        const val UPDATE_CHANNEL = "site.wenyou.app/app_update"
        const val KEYBOARD_INSETS_CHANNEL = "site.wenyou.app/keyboard_insets"
        const val RUNTIME_DIAGNOSTICS_CHANNEL = "site.wenyou.app/runtime_diagnostics"
        const val ENABLE_IMPELLER_METADATA = "io.flutter.embedding.android.EnableImpeller"
        const val APK_MIME_TYPE = "application/vnd.android.package-archive"
        const val UPDATE_LOG_TAG = "WenyouUpdate"
    }

    private var keyboardInsetsChannel: MethodChannel? = null
    private var keyboardInsetsActive = false
    private var appliedKeyboardInsetBottom = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING)
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EditorClipboardChannel(this).register(flutterEngine)
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
                        val expectedBuild = call.argument<Number>("expectedBuild")?.toLong()
                        if (expectedBuild == null || expectedBuild < 1) {
                            result.error("apk_invalid_build", "安装包目标构建号无效。", null)
                            return@setMethodCallHandler
                        }
                        installApk(filePath, expectedBuild, result)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RUNTIME_DIAGNOSTICS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getRuntimeInfo" -> result.success(runtimeDiagnostics())
                else -> result.notImplemented()
            }
        }
        keyboardInsetsChannel =
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                KEYBOARD_INSETS_CHANNEL,
            )
        installInstantKeyboardInsets()
    }

    override fun onResume() {
        super.onResume()
        keyboardInsetsActive = true
    }

    override fun onPause() {
        keyboardInsetsActive = false
        // Publish the neutral state before Flutter receives the inactive
        // lifecycle event, so it never falls back to a stale engine inset.
        dispatchKeyboardInsetTarget(0)
        super.onPause()
    }

    override fun onPostResume() {
        super.onPostResume()
        resetAndRequestKeyboardInsets()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            resetAndRequestKeyboardInsets()
        } else {
            appliedKeyboardInsetBottom = 0
            dispatchKeyboardInsetTarget(0)
        }
    }

    private fun installInstantKeyboardInsets() {
        val decorView = window.decorView
        ViewCompat.setOnApplyWindowInsetsListener(decorView) { view, insets ->
            appliedKeyboardInsetBottom =
                if (
                    keyboardInsetsActive &&
                    decorView.hasWindowFocus() &&
                    insets.isVisible(WindowInsetsCompat.Type.ime())
                ) {
                    insets.getInsets(WindowInsetsCompat.Type.ime()).bottom
                } else {
                    0
            }
            dispatchKeyboardInsetTarget(appliedKeyboardInsetBottom)
            ViewCompat.onApplyWindowInsets(view, insets)
        }
        ViewCompat.setWindowInsetsAnimationCallback(
            decorView,
            object : WindowInsetsAnimationCompat.Callback(
                WindowInsetsAnimationCompat.Callback.DISPATCH_MODE_CONTINUE_ON_SUBTREE,
            ) {
                override fun onStart(
                    animation: WindowInsetsAnimationCompat,
                    bounds: WindowInsetsAnimationCompat.BoundsCompat,
                ): WindowInsetsAnimationCompat.BoundsCompat {
                    if (animation.typeMask and WindowInsetsCompat.Type.ime() != 0) {
                        // Android has completed its end-state layout before onStart.
                        // The apply-insets listener has captured that final IME
                        // inset. Reuse it and never forward animation progress, so
                        // Flutter chrome does not chase every IME frame.
                        dispatchKeyboardInsetTarget(appliedKeyboardInsetBottom)
                    }
                    return bounds
                }

                override fun onProgress(
                    insets: WindowInsetsCompat,
                    runningAnimations: MutableList<WindowInsetsAnimationCompat>,
                ): WindowInsetsCompat = insets

                override fun onEnd(animation: WindowInsetsAnimationCompat) {
                    if (animation.typeMask and WindowInsetsCompat.Type.ime() != 0) {
                        ViewCompat.requestApplyInsets(decorView)
                    }
                }
            },
        )
        ViewCompat.requestApplyInsets(decorView)
    }

    private fun resetAndRequestKeyboardInsets() {
        appliedKeyboardInsetBottom = 0
        dispatchKeyboardInsetTarget(0)
        window.decorView.post {
            if (keyboardInsetsActive && window.decorView.hasWindowFocus()) {
                ViewCompat.requestApplyInsets(window.decorView)
            }
        }
    }

    private fun dispatchKeyboardInsetTarget(bottomPhysicalPixels: Int) {
        keyboardInsetsChannel?.invokeMethod(
            "keyboardInsetTargetChanged",
            mapOf("bottomPhysicalPixels" to bottomPhysicalPixels.toDouble()),
        )
    }

    private fun runtimeDiagnostics(): Map<String, Any> {
        val packageInfo = packageManager.getPackageInfo(packageName, 0)
        return mapOf(
            "appVersion" to (packageInfo.versionName ?: "unknown"),
            "buildNumber" to versionCodeOf(packageInfo).toString(),
            "operatingSystem" to "Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})",
            "deviceModel" to "${Build.MANUFACTURER} ${Build.MODEL}".trim(),
            "renderer" to if (isImpellerRequested()) {
                "impeller-requested"
            } else {
                "skia-opengles-requested"
            },
        )
    }

    private fun isImpellerRequested(): Boolean {
        @Suppress("DEPRECATION")
        val applicationInfo = packageManager.getApplicationInfo(
            packageName,
            PackageManager.GET_META_DATA,
        )
        return applicationInfo.metaData?.getBoolean(ENABLE_IMPELLER_METADATA, true) ?: true
    }

    private fun installApk(
        filePath: String,
        expectedBuild: Long,
        result: MethodChannel.Result,
    ) {
        try {
            val allowedDirectory = File(cacheDir, "wenyou_updates").canonicalFile
            val apk = File(filePath).canonicalFile
            val isInsideAllowedDirectory =
                apk.path.startsWith("${allowedDirectory.path}${File.separator}")
            if (!isInsideAllowedDirectory || !apk.isFile || apk.extension.lowercase() != "apk") {
                result.error("invalid_path", "安装包路径无效。", null)
                return
            }

            val signingFlags =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    PackageManager.GET_SIGNING_CERTIFICATES
                } else {
                    @Suppress("DEPRECATION")
                    PackageManager.GET_SIGNATURES
                }
            val archiveInfo = packageManager.getPackageArchiveInfo(apk.path, signingFlags)
            if (archiveInfo == null || archiveInfo.packageName != packageName) {
                result.error("apk_package_mismatch", "安装包与当前应用不匹配。", null)
                return
            }
            val archiveBuild = versionCodeOf(archiveInfo)
            val installedInfo = packageManager.getPackageInfo(packageName, signingFlags)
            val installedBuild = versionCodeOf(installedInfo)
            if (archiveBuild != expectedBuild || archiveBuild <= installedBuild) {
                result.error("apk_version_mismatch", "安装包版本与更新目标不一致。", null)
                return
            }
            if (!hasMatchingSigner(installedInfo, archiveInfo)) {
                result.error("apk_signature_mismatch", "安装包签名验证失败。", null)
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
            Log.e(UPDATE_LOG_TAG, "Native APK validation or installer launch failed.", error)
            result.error("installer_failed", "无法打开系统安装器。", error.javaClass.simpleName)
        }
    }

    private fun versionCodeOf(packageInfo: PackageInfo): Long {
        @Suppress("DEPRECATION")
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.longVersionCode
        } else {
            packageInfo.versionCode.toLong()
        }
    }

    private fun hasMatchingSigner(installed: PackageInfo, archive: PackageInfo): Boolean {
        val installedSigners = signaturesOf(installed)
        val archiveSigners = signaturesOf(archive)
        return installedSigners.isNotEmpty() &&
            archiveSigners.isNotEmpty() &&
            installedSigners.any { current ->
                archiveSigners.any { candidate -> current.toByteArray().contentEquals(candidate.toByteArray()) }
            }
    }

    private fun signaturesOf(packageInfo: PackageInfo): Array<Signature> {
        @Suppress("DEPRECATION")
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val signingInfo = packageInfo.signingInfo ?: return emptyArray()
            if (signingInfo.hasMultipleSigners()) {
                signingInfo.apkContentsSigners
            } else {
                signingInfo.signingCertificateHistory
            }
        } else {
            packageInfo.signatures ?: emptyArray()
        }
    }
}
