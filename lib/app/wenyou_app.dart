import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_cache_invalidation.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/startup_gate.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class WenyouApp extends StatelessWidget {
  const WenyouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
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
        return StartupGate(
          child: DailyCheckInBootstrap(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
