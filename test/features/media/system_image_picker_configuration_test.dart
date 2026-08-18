import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:wenyousite_mobile/features/media/data/system_image_picker_configuration.dart';

void main() {
  test('Android 启动配置显式启用系统 Photo Picker', () {
    final implementation = ImagePickerAndroid();
    expect(implementation.useAndroidPhotoPicker, isFalse);

    configureSystemImagePicker(implementation: implementation);

    expect(implementation.useAndroidPhotoPicker, isTrue);
  });

  test('非 Android 图片选择实现保持不变', () {
    final implementation = _FakeImagePickerPlatform();

    expect(
      () => configureSystemImagePicker(implementation: implementation),
      returnsNormally,
    );
  });
}

class _FakeImagePickerPlatform extends ImagePickerPlatform {}
