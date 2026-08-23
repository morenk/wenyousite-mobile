import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      key: const Key('auth-brand-header'),
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const WenyouBrandMark.decorative(
          key: Key('auth-brand-mark'),
          size: WenyouBrandContract.authMarkSize,
        ),
        SizedBox(width: tokens.space12),
        Text(
          WenyouBrandContract.name,
          style: Theme.of(context).textTheme.wenyouSectionTitle,
        ),
      ],
    );
  }
}
