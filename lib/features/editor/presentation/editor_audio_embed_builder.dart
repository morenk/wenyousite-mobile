import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_audio_embed.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_audio_player.dart';
import 'package:wenyousite_mobile/features/editor/presentation/audio_projected_quill_controller.dart';

class EditorAudioEmbedBuilder extends EmbedBuilder {
  const EditorAudioEmbedBuilder(this.audios, this.editorFocusNode);
  final Map<String, MediaAudio> audios;
  final FocusNode? editorFocusNode;
  @override
  String get key => MarkdownAudioEmbed.type;
  @override
  String toPlainText(Embed node) =>
      MarkdownAudioEmbed.content(
        node.value.data,
      )?.operations.map((op) => op.data as String).join() ??
      '音频';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final projection = MarkdownAudioEmbed.projection(
      embedContext.node.value.data,
      audios,
    );
    // 元数据只能来自当前编辑会话，剪贴板载荷本身没有播放权限。
    if (projection == null) return Text(toPlainText(embedContext.node));
    final controller = embedContext.controller;
    void select() {
      if (embedContext.readOnly) return;
      final offset = embedContext.node.documentOffset;
      final selected = TextSelection(
        baseOffset: offset,
        extentOffset: offset + 1,
      );
      if (controller is AudioProjectedQuillController) {
        controller.selectAudio(selected);
      } else {
        controller.updateSelection(selected, ChangeSource.local);
      }
      editorFocusNode?.requestFocus();
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final offset = embedContext.node.documentOffset;
        final selected =
            controller.selection.start <= offset &&
            controller.selection.end > offset;
        return DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: selected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
            borderRadius: BorderRadius.circular(
              context.wenyouTokens.radiusCompact,
            ),
          ),
          child: child,
        );
      },
      child: _AudioPointerRegion(
        child: Listener(
          onPointerDown: (event) {
            if (controller is AudioProjectedQuillController) {
              controller.beginAudioPointer(event.pointer);
            }
          },
          onPointerUp: (event) {
            if (controller is AudioProjectedQuillController) {
              controller.endAudioPointer(event.pointer);
            }
          },
          onPointerCancel: (event) {
            if (controller is AudioProjectedQuillController) {
              controller.endAudioPointer(event.pointer);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: select,
            child: WenyouAudioPlayer(
              key: ValueKey('editor-audio-${projection.audio.mediaId}'),
              audio: projection.audio,
              label: projection.label,
              labelRuns: projection.labelRuns,
            ),
          ),
        ),
      ),
    );
  }
}

// Quill 的透明点击识别器会与卡片控件同时收到事件；命中音频区域时
// 由卡片处理选择或播放，避免透明识别器随后把光标移到块边缘。
bool editorAudioOwnsPointer(BuildContext context, Offset position) {
  final result = HitTestResult();
  RendererBinding.instance.hitTestInView(
    result,
    position,
    View.of(context).viewId,
  );
  return result.path.any((entry) => entry.target is _AudioPointerBox);
}

class _AudioPointerRegion extends SingleChildRenderObjectWidget {
  const _AudioPointerRegion({required super.child});
  @override
  RenderObject createRenderObject(BuildContext context) => _AudioPointerBox();
}

class _AudioPointerBox extends RenderProxyBox {}
