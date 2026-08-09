import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "WenyouAppUpdate")
    let channel = FlutterMethodChannel(
      name: "site.wenyou.app/app_update",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "getInstalledAppInfo" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let version = Bundle.main.object(
        forInfoDictionaryKey: "CFBundleShortVersionString"
      ) as? String
      let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
      guard let version, let build else {
        result(
          FlutterError(
            code: "version_unavailable",
            message: "无法读取当前应用版本。",
            details: nil
          )
        )
        return
      }
      result(["version": version, "build": build])
    }
  }
}
