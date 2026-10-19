import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_composer_sheet.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_drafts.dart';
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
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final scope = ref.read(sessionScopeProvider);
        final drafts = ref.read(postComposerDraftsProvider);
        final key = postComposerDraftKey(target);
        void saveDraft(PostComposerDraft? draft) {
          if (ref.read(sessionScopeProvider) != scope) return;
          setPostComposerDraft(drafts, key, draft);
          onDraftChanged?.call(draft);
        }

        return PostComposerOpening(
          target: target,
          initialDraft: initialDraft ?? drafts[key],
          onDraftChanged: saveDraft,
          builder: (context, composer) => PostComposerRouteHost(
            localDraftTarget: composer.localDraftTarget,
            initialInsertion:
                target.kind == PostComposerKind.createFloor ||
                    target.kind == PostComposerKind.createReply
                ? target.initialContent
                : null,
            supportsRpIdentity: supportsRpIdentity,
            publishDraft: composer.publishDraft,
            target: composer.target,
            baseline: composer.baseline,
            onDraftChanged: composer.isolatedLegacyDraft ? null : saveDraft,
          ),
        );
      },
    ),
  );
}
