import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_session_bootstrap.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/profile_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_controllers.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

String walletSessionKey(WidgetRef ref) {
  return ref.read(sessionControllerProvider.notifier).currentUserId ??
      'authenticated-session';
}

@Deprecated('Use AppSessionBootstrap at the app composition boundary.')
class DailyCheckInBootstrap extends AppSessionBootstrap {
  const DailyCheckInBootstrap({required super.child, super.key});
}

class WenyouTipButton extends ConsumerWidget {
  const WenyouTipButton({
    required this.target,
    required this.recipientName,
    required this.returnTo,
    this.onSuccess,
    this.expanded = false,
    this.iconOnly = false,
    super.key,
  });

  final TipTarget target;
  final String recipientName;
  final String returnTo;
  final FutureOr<void> Function(TipResult result)? onSuccess;
  final bool expanded;
  final bool iconOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (iconOnly) {
      return IconButton(
        onPressed: () => showWenyouTipFlow(
          context: context,
          ref: ref,
          target: target,
          recipientName: recipientName,
          returnTo: returnTo,
          onSuccess: onSuccess,
        ),
        tooltip: '加油',
        icon: const WenyouIcon(WenyouIconIds.actionTip),
      );
    }
    final button = OutlinedButton.icon(
      onPressed: () => showWenyouTipFlow(
        context: context,
        ref: ref,
        target: target,
        recipientName: recipientName,
        returnTo: returnTo,
        onSuccess: onSuccess,
      ),
      icon: const WenyouIcon(WenyouIconIds.actionTip),
      label: const Text('加油'),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

Future<void> showWenyouTipFlow({
  required BuildContext context,
  required WidgetRef ref,
  required TipTarget target,
  required String recipientName,
  required String returnTo,
  FutureOr<void> Function(TipResult result)? onSuccess,
}) async {
  if (!ref.read(sessionControllerProvider).isAuthenticated) {
    await context.pushNamed<Object?>(
      'login',
      queryParameters: {'returnTo': returnTo},
    );
    return;
  }
  final result = await showDialog<TipResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        _TipDialog(target: target, recipientName: recipientName),
  );
  if (result == null || !context.mounted) return;
  final sessionKey = walletSessionKey(ref);
  ref.invalidate(walletControllerProvider(sessionKey));
  ref.read(profileCacheInvalidatorProvider)(target.recipientUserId);
  await onSuccess?.call(result);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('已加油 ${WenyouAmount.format(result.grossAmount)} 升')),
  );
}

class _TipDialog extends ConsumerStatefulWidget {
  const _TipDialog({required this.target, required this.recipientName});

  final TipTarget target;
  final String recipientName;

  @override
  ConsumerState<_TipDialog> createState() => _TipDialogState();
}

class _TipDialogState extends ConsumerState<_TipDialog> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '2');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final provider = tipControllerProvider(widget.target);
    final state = ref.watch(provider);
    return PopScope(
      canPop: !state.isSubmitting,
      child: AlertDialog(
        title: Text('为${widget.recipientName}加油'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('tip-amount'),
                controller: _amountController,
                enabled: !state.isSubmitting,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '投入升数',
                  suffixText: '升',
                ),
                onSubmitted: state.isSubmitting ? null : (_) => _submit(),
              ),
              if (state.failure != null) ...[
                SizedBox(height: tokens.space12),
                WenyouStatusBanner(
                  tone: WenyouStatusTone.error,
                  message: state.failure!.userMessage,
                  detail: state.failure!.requestId == null
                      ? null
                      : '问题编号：${state.failure!.requestId}',
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: state.isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('tip-submit'),
            onPressed: state.isSubmitting ? null : _submit,
            child: state.isSubmitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('确认加油'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final result = await ref
        .read(tipControllerProvider(widget.target).notifier)
        .submit(_amountController.text);
    if (result != null && mounted) Navigator.pop(context, result);
  }
}
