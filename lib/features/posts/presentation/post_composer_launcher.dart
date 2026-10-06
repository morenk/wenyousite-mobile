import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_composer_sheet.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'post_composer_host.dart';
import 'post_composer_opening.dart';

Future<PostItem?> showPostComposerSheet({
  required BuildContext context,
  required PostComposerTarget target,
  PostComposerDraft? initialDraft,
  ValueChanged<PostComposerDraft?>? onDraftChanged,
  bool supportsRpIdentity = false,
}) {
  return showWenyouComposerSheet<PostItem>(
    context: context,
    isDismissible: false,
    builder: (context) => PostComposerOpening(
      target: target,
      initialDraft: initialDraft,
      onDraftChanged: onDraftChanged,
      builder: (context, composer) => PostComposerRouteHost(
        initialInsertion:
            target.kind == PostComposerKind.createFloor ||
                target.kind == PostComposerKind.createReply
            ? target.initialContent
            : null,
        supportsRpIdentity: supportsRpIdentity,
        publishDraft: composer.publishDraft,
        target: composer.target,
        baseline: composer.baseline,
        onDraftChanged: onDraftChanged,
      ),
    ),
  );
}
