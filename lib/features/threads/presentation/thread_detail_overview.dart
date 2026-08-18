import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_subthread_navigator.dart';

class ThreadDetailOverview extends StatelessWidget {
  const ThreadDetailOverview({
    required this.detail,
    required this.selectedSubthreadId,
    required this.onSubthreadSelected,
    super.key,
  });

  final ThreadDetailModel detail;
  final String? selectedSubthreadId;
  final ValueChanged<String> onSubthreadSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      key: const Key('thread-detail-overview'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.space4),
          child: Semantics(
            header: true,
            child: Text(
              detail.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.wenyouDetailTitle,
            ),
          ),
        ),
        if (detail.subthreads.isNotEmpty && selectedSubthreadId != null) ...[
          SizedBox(height: tokens.space12),
          ThreadSubthreadNavigator(
            subthreads: detail.subthreads,
            selectedSubthreadId: selectedSubthreadId!,
            onSelected: onSubthreadSelected,
          ),
        ],
        SizedBox(height: tokens.space12),
        Divider(height: 1, color: tokens.border),
      ],
    );
  }
}
