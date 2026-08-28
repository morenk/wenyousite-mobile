import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class WenyouPageFailureState extends StatelessWidget {
  const WenyouPageFailureState({
    required this.title,
    required this.failure,
    required this.onRetry,
    this.message,
    this.retryLabel = '重新加载',
    this.icon = WenyouIconIds.statusOffline,
    this.maxWidth,
    this.retryKey,
    super.key,
  });

  final String title;
  final ApiFailure? failure;
  final VoidCallback onRetry;
  final String? message;
  final String retryLabel;
  final String icon;
  final double? maxWidth;
  final Key? retryKey;

  @override
  Widget build(BuildContext context) {
    final presentation = UserFacingFailure.fromApi(
      failure,
      title: title,
      message: message,
      placement: FailurePresentationPlacement.page,
    );
    return WenyouPageBody(
      maxWidth: maxWidth,
      child: WenyouPanel(
        child: WenyouFailureView(
          failure: presentation,
          icon: icon,
          action: OutlinedButton.icon(
            key: retryKey,
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: Text(retryLabel),
          ),
        ),
      ),
    );
  }
}
