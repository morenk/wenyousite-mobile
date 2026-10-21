import Flutter
import Photos
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var imageGalleryChannel: ImageGalleryChannel?
  private var clipboardNavigationChannel: FlutterMethodChannel?
  private var audioDocumentSaver: AudioDocumentSaverChannel?

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
    imageGalleryChannel = ImageGalleryChannel(messenger: registrar.messenger())
    imageGalleryChannel?.register()
    audioDocumentSaver = AudioDocumentSaverChannel(messenger: registrar.messenger())
    clipboardNavigationChannel = FlutterMethodChannel(
      name: "site.wenyou.app/clipboard_navigation",
      binaryMessenger: registrar.messenger()
    )
    clipboardNavigationChannel?.setMethodCallHandler { call, result in
      let pasteboard = UIPasteboard.general
      switch call.method {
      case "getChangeToken":
        result("ios:\(pasteboard.changeCount)")
      case "writeText":
        guard let arguments = call.arguments as? [String: Any],
              let text = arguments["text"] as? String else {
          result(FlutterError(code: "invalid_text", message: "复制内容不可用。", details: nil))
          return
        }
        pasteboard.string = text
        result("ios:\(pasteboard.changeCount)")
      case "readSnapshot":
        guard let text = pasteboard.string else {
          result(nil)
          return
        }
        result([
          "text": text,
          "changeToken": "ios:\(pasteboard.changeCount)",
        ])
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

/// 系统导出私有 MP3 文件，iOS 13 可用，不申请相册或全盘权限。
private final class AudioDocumentSaverChannel: NSObject, UIDocumentPickerDelegate,
  UIAdaptivePresentationControllerDelegate {
  private let channel: FlutterMethodChannel
  private var pending: FlutterResult?
  private var operationId: String?
  private weak var picker: UIDocumentPickerViewController?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "site.wenyou.app/document_saver", binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: "保存服务不可用。", details: nil))
        return
      }
      if call.method == "cancelAudio" {
        if let arguments = call.arguments as? [String: Any],
           arguments["id"] as? String == self.operationId {
          self.picker?.dismiss(animated: false)
          self.finish(false)
        }
        result(nil)
      } else if call.method == "saveAudio" {
        self.save(call, result: result)
      } else { result(FlutterMethodNotImplemented) }
    }
  }

  private func save(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard pending == nil,
      let args = call.arguments as? [String: Any],
      let id = args["id"] as? String,
      let path = args["filePath"] as? String,
      let name = args["fileName"] as? String,
      args["mimeType"] as? String == "audio/mpeg",
      (name as NSString).lastPathComponent == name,
      (name as NSString).pathExtension.lowercased() == "mp3"
    else {
      result(FlutterError(code: "invalid_audio", message: "音频保存参数不可用。", details: nil))
      return
    }
    let source = URL(fileURLWithPath: path).resolvingSymlinksInPath().standardizedFileURL
    let temporary = URL(fileURLWithPath: NSTemporaryDirectory()).resolvingSymlinksInPath().standardizedFileURL
    let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
      .resolvingSymlinksInPath().standardizedFileURL
    let roots = [temporary.path, cache?.path].compactMap { $0 }
    guard roots.contains(where: { source.path.hasPrefix($0.hasSuffix("/") ? $0 : $0 + "/") }),
      source.pathExtension.lowercased() == "mp3",
      let attributes = try? FileManager.default.attributesOfItem(atPath: source.path),
      let size = attributes[.size] as? NSNumber, size.intValue > 0,
      size.intValue <= 30 * 1024 * 1024,
      var presenter = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene })
        .flatMap({ $0.windows }).first(where: { $0.isKeyWindow })?.rootViewController
    else {
      result(FlutterError(code: "invalid_audio", message: "音频文件不可用。", details: nil))
      return
    }
    while let next = presenter.presentedViewController { presenter = next }
    let controller = UIDocumentPickerViewController(url: source, in: .exportToService)
    controller.delegate = self
    operationId = id
    pending = result
    picker = controller
    presenter.present(controller, animated: true)
    controller.presentationController?.delegate = self
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    finish(!urls.isEmpty)
  }
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { finish(false) }
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) { finish(false) }
  private func finish(_ saved: Bool) {
    let completion = pending
    pending = nil
    operationId = nil
    picker = nil
    completion?(saved)
  }
}

private final class ImageGalleryChannel {
  private static let maximumBytes = 10 * 1024 * 1024

  private let channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "site.wenyou.app/image_gallery",
      binaryMessenger: messenger
    )
  }

  func register() {
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(
          FlutterError(
            code: "save_failed",
            message: "图片保存服务暂时不可用。",
            details: nil
          )
        )
        return
      }
      switch call.method {
      case "requestAddPermission":
        self.requestAddPermission(result)
      case "saveImage":
        self.saveImage(call, result: result)
      case "openSettings":
        self.openSettings(result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func requestAddPermission(_ result: @escaping FlutterResult) {
    if #available(iOS 14, *) {
      let current = PHPhotoLibrary.authorizationStatus(for: .addOnly)
      if current != .notDetermined {
        result(permissionResult(current))
        return
      }
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        DispatchQueue.main.async { result(self.permissionResult(status)) }
      }
      return
    }
    let current = PHPhotoLibrary.authorizationStatus()
    if current != .notDetermined {
      result(permissionResult(current))
      return
    }
    PHPhotoLibrary.requestAuthorization { status in
      DispatchQueue.main.async { result(self.permissionResult(status)) }
    }
  }

  private func permissionResult(_ status: PHAuthorizationStatus) -> String {
    if #available(iOS 14, *), status == .limited {
      return "granted"
    }
    switch status {
    case .authorized:
      return "granted"
    case .denied, .restricted:
      return "settingsRequired"
    case .notDetermined:
      return "denied"
    @unknown default:
      return "denied"
    }
  }

  private func saveImage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let filePath = arguments["filePath"] as? String,
      let fileName = arguments["fileName"] as? String,
      let mimeType = arguments["mimeType"] as? String,
      let source = validatedSource(
        filePath: filePath,
        fileName: fileName,
        mimeType: mimeType
      )
    else {
      result(
        FlutterError(
          code: "unsupported_format",
          message: "图片文件无效。",
          details: nil
        )
      )
      return
    }

    PHPhotoLibrary.shared().performChanges {
      let request = PHAssetCreationRequest.forAsset()
      let options = PHAssetResourceCreationOptions()
      options.originalFilename = source.fileName
      request.addResource(with: .photo, fileURL: source.url, options: options)
    } completionHandler: { success, error in
      DispatchQueue.main.async {
        if success {
          result(nil)
        } else {
          result(
            FlutterError(
              code: "save_failed",
              message: "图片未能写入系统相册。",
              details: error.map { String(describing: type(of: $0)) }
            )
          )
        }
      }
    }
  }

  private func validatedSource(
    filePath: String,
    fileName: String,
    mimeType: String
  ) -> ImageSource? {
    guard
      fileName.range(
        of: #"^[A-Za-z0-9._-]{1,160}$"#,
        options: .regularExpression
      ) != nil
    else { return nil }
    let extensionName = (fileName as NSString).pathExtension.lowercased()
    let expectedMime: String
    switch extensionName {
    case "jpg", "jpeg": expectedMime = "image/jpeg"
    case "png": expectedMime = "image/png"
    case "gif": expectedMime = "image/gif"
    case "webp": expectedMime = "image/webp"
    case "avif": expectedMime = "image/avif"
    default: return nil
    }
    guard mimeType == expectedMime else { return nil }

    let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
      .standardizedFileURL
    let fileURL = URL(fileURLWithPath: filePath).standardizedFileURL
    let temporaryPrefix = temporaryDirectory.path.hasSuffix("/")
      ? temporaryDirectory.path
      : temporaryDirectory.path + "/"
    guard
      fileURL.path.hasPrefix(temporaryPrefix),
      FileManager.default.fileExists(atPath: fileURL.path),
      let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
      let fileSize = attributes[.size] as? NSNumber,
      fileSize.intValue > 0,
      fileSize.intValue <= Self.maximumBytes
    else { return nil }
    return ImageSource(url: fileURL, fileName: fileName)
  }

  private func openSettings(_ result: @escaping FlutterResult) {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      result(
        FlutterError(
          code: "settings_unavailable",
          message: "系统设置无法打开。",
          details: nil
        )
      )
      return
    }
    UIApplication.shared.open(url, options: [:]) { opened in
      if opened {
        result(nil)
      } else {
        result(
          FlutterError(
            code: "settings_unavailable",
            message: "系统设置无法打开。",
            details: nil
          )
        )
      }
    }
  }

  private struct ImageSource {
    let url: URL
    let fileName: String
  }
}
