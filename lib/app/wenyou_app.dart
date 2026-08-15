import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/profile_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_instant_keyboard_insets.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/startup_gate.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class WenyouApp extends StatelessWidget {
  const WenyouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        avatarImagePickerPortProvider.overrideWith(
          (ref) => ref.watch(avatarImagePickerProvider),
        ),
        editorImagePickerPortProvider.overrideWith(
          (ref) => ref.watch(editorImagePickerProvider),
        ),
        mediaUploadGatewayPortProvider.overrideWith(
          (ref) => ref.watch(mediaUploadGatewayAdapterProvider),
        ),
        appCapabilitiesProvider.overrideWith((ref) {
          final contract = ref.watch(
            startupControllerProvider.select((state) => state.contract),
          );
          return AppCapabilities(
            stickers: contract?.stickersEnabled ?? false,
            directMessages: contract?.directMessagesEnabled ?? false,
            pushNotifications: contract?.pushNotificationsEnabled ?? false,
          );
        }),
        profileCacheInvalidatorProvider.overrideWith((ref) {
          return (userId) {
            ref.invalidate(meProfileControllerProvider);
            if (userId != null) {
              ref.invalidate(publicUserControllerProvider(userId));
            }
          };
        }),
      ],
      child: const _WenyouMaterialApp(),
    );
  }
}

class _WenyouMaterialApp extends ConsumerWidget {
  const _WenyouMaterialApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '温油站',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        return WenyouInstantKeyboardInsets(
          child: StartupGate(
            child: DailyCheckInBootstrap(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
