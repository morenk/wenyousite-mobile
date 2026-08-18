import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void configureSystemImagePicker({ImagePickerPlatform? implementation}) {
  final activeImplementation = implementation ?? ImagePickerPlatform.instance;
  if (activeImplementation is ImagePickerAndroid) {
    // Avoid OEM ACTION_GET_CONTENT result-delivery failures and enable the
    // platform-enforced selection limit used by multi-image flows.
    activeImplementation.useAndroidPhotoPicker = true;
  }
}
