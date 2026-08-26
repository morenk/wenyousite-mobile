import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/app/app_session_bootstrap.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_instant_keyboard_insets.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/background_notification_navigation.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/startup_gate.dart';

const wenyouLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  FlutterQuillLocalizations.delegate,
];

class WenyouApp extends StatelessWidget {
  const WenyouApp({this.enableDebugDiagnosticConsole = false, super.key});

  final bool enableDebugDiagnosticConsole;

  @override
  Widget build(BuildContext context) {
    return _WenyouMaterialApp(
      enableDebugDiagnosticConsole: enableDebugDiagnosticConsole,
    );
  }
}

class _WenyouMaterialApp extends ConsumerWidget {
  const _WenyouMaterialApp({required this.enableDebugDiagnosticConsole});

  final bool enableDebugDiagnosticConsole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(
      appearancePreferenceControllerProvider.select(
        (state) => state.preference,
      ),
    );
    return MaterialApp.router(
      title: '温油站',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: appearance.themeMode,
      themeAnimationStyle: AnimationStyle.noAnimation,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      localizationsDelegates: wenyouLocalizationsDelegates,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        final theme = Theme.of(context);
        final tokens = context.wenyouTokens;
        final iconBrightness = theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark;
        final app = StartupGate(
          child: AppSessionBootstrap(
            child: BackgroundNotificationNavigation(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: tokens.background,
            statusBarIconBrightness: iconBrightness,
            statusBarBrightness: theme.brightness,
            systemNavigationBarColor: tokens.panel,
            systemNavigationBarDividerColor: tokens.border,
            systemNavigationBarIconBrightness: iconBrightness,
          ),
          child: WenyouInstantKeyboardInsets(
            child: enableDebugDiagnosticConsole
                ? WenyouDebugDiagnosticOverlay(child: app)
                : app,
          ),
        );
      },
    );
  }
}
