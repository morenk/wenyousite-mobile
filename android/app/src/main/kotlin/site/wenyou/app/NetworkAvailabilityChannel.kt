package site.wenyou.app

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/** 只报告默认网络可用性，不探测公网、不改变网络、不承诺目标服务器可达。 */
class NetworkAvailabilityChannel(context: Context) : EventChannel.StreamHandler {
    private val manager = context.getSystemService(ConnectivityManager::class.java)
    private val mainHandler = Handler(Looper.getMainLooper())
    private var channel: EventChannel? = null
    private var callback: ConnectivityManager.NetworkCallback? = null
    private var sink: EventChannel.EventSink? = null
    private var currentNetwork: Network? = null
    private var lastValue: Boolean? = null

    fun register(engine: FlutterEngine) {
        channel = EventChannel(engine.dartExecutor.binaryMessenger, "site.wenyou.app/network_availability")
            .also { it.setStreamHandler(this) }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        stop()
        sink = events
        val listener = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                if (sink !== events) return
                currentNetwork = network
                // API26会随后回调能力；不在onAvailable同步查询造成竞态。
            }

            override fun onCapabilitiesChanged(network: Network, capabilities: NetworkCapabilities) {
                if (sink !== events || network != currentNetwork) return
                emit(
                    capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                        capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED),
                    events,
                )
            }

            override fun onLost(network: Network) {
                if (sink !== events || network != currentNetwork) return
                currentNetwork = null
                emit(false, events)
            }
        }
        try {
            manager.registerDefaultNetworkCallback(listener, mainHandler)
            callback = listener
        } catch (_: RuntimeException) {
            // 诊断通道不可用时由字体资源自身的有界退避继续恢复。
            events.error("network_observer_unavailable", "网络状态监听不可用", null)
            sink = null
        }
    }

    private fun emit(value: Boolean, target: EventChannel.EventSink) {
        if (sink !== target || lastValue == value) return
        lastValue = value
        target.success(value)
    }

    override fun onCancel(arguments: Any?) = stop()

    private fun stop() {
        sink = null
        callback?.let { manager.unregisterNetworkCallback(it) }
        callback = null
        currentNetwork = null
        lastValue = null
    }

    fun dispose() {
        stop()
        channel?.setStreamHandler(null)
        channel = null
    }
}
