import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

class WenyouVerificationCodeField extends StatelessWidget {
  const WenyouVerificationCodeField({
    required this.controller,
    this.textFieldKey,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final Key? textFieldKey;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: textFieldKey,
      controller: controller,
      enabled: enabled,
      autofillHints: const [AutofillHints.oneTimeCode],
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      maxLength: 6,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) => value?.length == 6 ? null : '请输入 6 位数字验证码',
      decoration: const InputDecoration(
        labelText: '6 位验证码',
        counterText: '',
        prefixIcon: WenyouIcon(WenyouIconIds.statusVerified),
      ),
    );
  }
}
