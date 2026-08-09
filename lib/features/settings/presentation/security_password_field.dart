import 'package:flutter/material.dart';

class SecurityPasswordField extends StatefulWidget {
  const SecurityPasswordField({
    required this.textFieldKey,
    required this.controller,
    required this.label,
    required this.enabled,
    this.helperText,
    this.autofillHints,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
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

  @override
  State<SecurityPasswordField> createState() => _SecurityPasswordFieldState();
}

class _SecurityPasswordFieldState extends State<SecurityPasswordField> {
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
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: widget.enabled
              ? () => setState(() => _obscureText = !_obscureText)
              : null,
          tooltip: _obscureText ? '显示密码' : '隐藏密码',
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
