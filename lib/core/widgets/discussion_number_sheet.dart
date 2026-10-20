import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';

/// 定位过程留在抽屉内，失败时保留输入和原来的阅读位置。
Future<void> showDiscussionNumberSheet({
  required BuildContext context,
  required bool replies,
  required int? currentNumber,
  required int maxNumber,
  required Future<void> Function(int number, bool Function() active) onLocate,
}) => showWenyouSheet<void>(
  context: context,
  builder: (_) => DiscussionNumberSheet(
    replies: replies,
    currentNumber: currentNumber,
    maxNumber: maxNumber,
    onLocate: onLocate,
  ),
);

class DiscussionNumberSheet extends StatefulWidget {
  const DiscussionNumberSheet({
    required this.replies,
    required this.currentNumber,
    required this.maxNumber,
    required this.onLocate,
    super.key,
  });

  final bool replies;
  final int? currentNumber;
  final int maxNumber;
  final Future<void> Function(int number, bool Function() active) onLocate;

  @override
  State<DiscussionNumberSheet> createState() => _DiscussionNumberSheetState();
}

class _DiscussionNumberSheetState extends State<DiscussionNumberSheet> {
  final _input = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _input.text.trim().isEmpty) return;
    final route = ModalRoute.of(context);
    bool active() =>
        mounted && route?.isActive == true && route?.isCurrent == true;
    final number = int.tryParse(_input.text.trim());
    if (number == null || number < 1 || number > widget.maxNumber) {
      setState(() => _error = '请输入 1 至 ${widget.maxNumber} 之间的编号');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onLocate(number, active);
      if (mounted && active()) Navigator.of(context).pop();
    } on Object catch (error) {
      if (!active()) return;
      setState(() {
        _busy = false;
        _error = error is ApiFailure ? error.userMessage : '定位失败，请重试';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouSheetBody(
      title: widget.replies ? '跳转到回复' : '跳转到楼层',
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                [
                  if (widget.currentNumber case final number?) '当前 #$number',
                  '编号至 #${widget.maxNumber}',
                ].join(' · '),
                style: Theme.of(
                  context,
                ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
              ),
              SizedBox(height: tokens.space16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('discussion-number-input'),
                      controller: _input,
                      enabled: !_busy,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.go,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: widget.replies ? '回复编号' : '楼层号',
                        errorText: _error,
                        errorMaxLines: 3,
                      ),
                      onChanged: (_) => setState(() => _error = null),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  SizedBox(width: tokens.space8),
                  FilledButton(
                    key: const Key('discussion-number-submit'),
                    onPressed: _busy || _input.text.trim().isEmpty
                        ? null
                        : _submit,
                    child: Text(_busy ? '定位中' : '前往'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
