import 'package:wenyousite_mobile/core/config/app_environment.dart';

/// 保留线上原键，所有预览偏好按反馈批次隔离。
String environmentPreferenceKey(String key) =>
    AppEnvironment.fromDefines().storageName(key);
