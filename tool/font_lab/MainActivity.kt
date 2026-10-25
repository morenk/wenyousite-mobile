package site.wenyou.fontlab

import android.os.Debug
import android.os.Process
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "wenyou.fontlab/memory")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "configuration" -> result.success(intent.getStringExtra("font_lab_mode") ?: "typical")
                    "sample" -> {
                        val memory = Debug.MemoryInfo()
                        Debug.getMemoryInfo(memory)
                        result.success(mapOf(
                            "pid" to Process.myPid(),
                            "totalPssKb" to memory.totalPss,
                            "nativePssKb" to memory.nativePss,
                            "dalvikPssKb" to memory.dalvikPss,
                            "otherPssKb" to memory.otherPss,
                            "nativeHeapAllocatedBytes" to Debug.getNativeHeapAllocatedSize(),
                            "nativeHeapSizeBytes" to Debug.getNativeHeapSize(),
                        ))
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
