import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/thread_font_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class ThreadFontSettingsPage extends ConsumerStatefulWidget {
  const ThreadFontSettingsPage({super.key});

  @override
  ConsumerState<ThreadFontSettingsPage> createState() =>
      _ThreadFontSettingsPageState();
}

class _ThreadFontSettingsPageState
    extends ConsumerState<ThreadFontSettingsPage> {
  ThreadFontPreference? _preview;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadFontPreferenceControllerProvider);
    final controller = ref.read(
      threadFontPreferenceControllerProvider.notifier,
    );
    final preference = _preview ?? state.preference;
    final tokens = context.wenyouTokens;
    return WenyouSettingsTypography(
      child: Scaffold(
        backgroundColor: wenyouPersonalPageBackground(context),
        appBar: AppBar(
          backgroundColor: wenyouPersonalPageBackground(context),
          title: const Text('主题帖字号'),
        ),
        body: WenyouSettingsBody(
          children: [
            WenyouSettingsGroup(
              title: '预览',
              children: [
                SizedBox(
                  // 预览字号变化不能推移正在拖动的滑杆；长文可在预览内滚动。
                  height: tokens.minimumTouchTarget * 5,
                  child: SingleChildScrollView(
                    primary: false,
                    padding: EdgeInsets.all(tokens.space16),
                    child: WenyouMarkdown(
                      key: const Key('thread-font-preview'),
                      data:
                          '阳光落在打开的书页上。\n\n'
                          '「下一段故事，会从哪里开始？」\n\n'
                          '有人写下新的篇章，也有人停下来，静静读完这一刻。',
                      bodyFontSize: preference.fontSize,
                    ),
                  ),
                ),
              ],
            ),
            WenyouSettingsGroup(
              children: [
                Padding(
                  padding: EdgeInsets.all(tokens.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        preference.displayLabel,
                        key: const Key('thread-font-current'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.wenyouRowTitle,
                      ),
                      SizedBox(height: tokens.space8),
                      Semantics(
                        label: '主题帖字号',
                        child: Slider(
                          key: const Key('thread-font-slider'),
                          value: preference.index.toDouble(),
                          max: (ThreadFontPreference.values.length - 1)
                              .toDouble(),
                          divisions: ThreadFontPreference.values.length - 1,
                          label: preference.displayLabel,
                          semanticFormatterCallback: (value) =>
                              ThreadFontPreference
                                  .values[value.round()]
                                  .displayLabel,
                          onChanged: state.isSaving
                              ? null
                              : (value) => setState(() {
                                  _preview = ThreadFontPreference
                                      .values[value.round()];
                                }),
                          onChangeEnd: (value) {
                            setState(() => _preview = null);
                            unawaited(
                              controller.select(
                                ThreadFontPreference.values[value.round()],
                              ),
                            );
                          },
                        ),
                      ),
                      ExcludeSemantics(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '小',
                              style: Theme.of(context).textTheme.wenyouCaption,
                            ),
                            Text(
                              '超大',
                              style: Theme.of(context).textTheme.wenyouCaption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.space16),
              child: Text(
                '仅调整主题帖正文、楼层和回复的字号。',
                style: Theme.of(
                  context,
                ).textTheme.wenyouCompactBody.copyWith(color: tokens.mutedText),
              ),
            ),
            if (state.failureMessage case final message?)
              WenyouSettingsFailure(
                message: message,
                retryKey: const Key('thread-font-retry'),
                onRetry: state.isSaving
                    ? null
                    : () => unawaited(controller.retry()),
              ),
            Center(
              child: TextButton(
                key: const Key('thread-font-reset'),
                onPressed:
                    state.isSaving ||
                        (preference == ThreadFontPreference.standard &&
                            !state.readFailed)
                    ? null
                    : () {
                        setState(() => _preview = null);
                        unawaited(
                          controller.select(ThreadFontPreference.standard),
                        );
                      },
                child: const Text('恢复默认'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
