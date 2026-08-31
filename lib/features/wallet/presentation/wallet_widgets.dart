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
  showWenyouSnackBar(
    context,
    '已加油 ${WenyouAmount.format(result.grossAmount)} 升',
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
  final FocusNode _amountFocusNode = FocusNode();
  var _customAmount = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '2');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
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
              Wrap(
                spacing: tokens.space8,
                runSpacing: tokens.space8,
                children: [
                  for (final amount in const [2, 5, 10])
                    _TipAmountButton(
                      amount: amount,
                      selected:
                          !_customAmount &&
                          _amountController.text == amount.toString(),
                      enabled: !state.isSubmitting,
                      onPressed: () => setState(() {
                        _customAmount = false;
                        _amountController.text = amount.toString();
                      }),
                    ),
                  _TipAmountButton(
                    selected: _customAmount,
                    enabled: !state.isSubmitting,
                    onPressed: () {
                      setState(() {
                        if (!_customAmount) _amountController.clear();
                        _customAmount = true;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _amountFocusNode.requestFocus();
                      });
                    },
                  ),
                ],
              ),
              if (_customAmount) ...[
                SizedBox(height: tokens.space12),
                TextField(
                  key: const Key('tip-amount'),
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  enabled: !state.isSubmitting,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: '其他升数',
                    suffixText: '升',
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: state.isSubmitting ? null : (_) => _submit(),
                ),
              ],
              if (state.failure != null) ...[
                SizedBox(height: tokens.space12),
                WenyouStatusBanner(
                  tone: WenyouStatusTone.error,
                  message: state.failure!.userMessage,
                  detail: wenyouFailureDetail(
                    state.failure,
                    treatAsWrite: true,
                  ),
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
          WenyouAsyncButton(
            key: const Key('tip-submit'),
            label: _amountController.text.isEmpty
                ? '确认加油'
                : '确认加油 ${_amountController.text} 升',
            loadingLabel: '正在加油',
            isLoading: state.isSubmitting,
            onPressed: state.isSubmitting ? null : _submit,
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

class _TipAmountButton extends StatelessWidget {
  const _TipAmountButton({
    required this.selected,
    required this.enabled,
    required this.onPressed,
    this.amount,
  });

  final int? amount;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = amount == null ? '其他' : '$amount 升';
    return Semantics(
      selected: selected,
      child: OutlinedButton(
        key: Key(amount == null ? 'tip-amount-other' : 'tip-amount-$amount'),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected
              ? context.wenyouTokens.accentedBackground
              : null,
          foregroundColor: selected
              ? context.wenyouTokens.brandForeground
              : null,
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(label),
      ),
    );
  }
}
