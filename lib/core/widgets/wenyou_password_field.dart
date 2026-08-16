import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

class WenyouPasswordField extends StatefulWidget {
  const WenyouPasswordField({
    required this.textFieldKey,
    required this.controller,
    required this.label,
    required this.enabled,
    this.helperText,
    this.autofillHints,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.prefixIcon = WenyouIconIds.actionLock,
    super.key,
  });

  final Key textFieldKey;
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final String? helperText;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final String? Function(String? value)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final String prefixIcon;

  @override
  State<WenyouPasswordField> createState() => _WenyouPasswordFieldState();
}

class _WenyouPasswordFieldState extends State<WenyouPasswordField> {
  var _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.textFieldKey,
      controller: widget.controller,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        prefixIcon: WenyouIcon(widget.prefixIcon),
        suffixIcon: IconButton(
          onPressed: widget.enabled
              ? () => setState(() => _obscureText = !_obscureText)
              : null,
          tooltip: _obscureText ? '显示密码' : '隐藏密码',
          icon: WenyouIcon(
            _obscureText ? WenyouIconIds.actionShow : WenyouIconIds.actionHide,
          ),
        ),
      ),
    );
  }
}
