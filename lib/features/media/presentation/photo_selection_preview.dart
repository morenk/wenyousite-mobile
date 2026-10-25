import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/application/photo_selection_controller.dart';
import 'package:wenyousite_mobile/features/media/presentation/local_photo_thumbnail.dart';

class PhotoSelectionPreview extends StatefulWidget {
  const PhotoSelectionPreview({
    required this.photos,
    required this.initialIndex,
    required this.controller,
    required this.onPageChanged,
    super.key,
  });
  final List<LocalPhoto> photos;
  final int initialIndex;
  final PhotoSelectionController controller;
  final ValueChanged<int> onPageChanged;
  @override
  State<PhotoSelectionPreview> createState() => _PhotoSelectionPreviewState();
}

class _PhotoSelectionPreviewState extends State<PhotoSelectionPreview> {
  late final _pages = PageController(initialPage: widget.initialIndex);
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageView.builder(
    key: const Key('photo-preview-pages'),
    controller: _pages,
    itemCount: widget.photos.length,
    onPageChanged: widget.onPageChanged,
    itemBuilder: (context, index) {
      final photo = widget.photos[index];
      return Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: SizedBox.expand(
              child: LocalPhotoThumbnail(
                library: widget.controller.library,
                photo: photo,
                size: 1440,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: PhotoSelectionMark(
              photo: photo,
              controller: widget.controller,
              label: '当前图片',
            ),
          ),
        ],
      );
    },
  );
}

class PhotoSelectionMark extends StatelessWidget {
  const PhotoSelectionMark({
    required this.photo,
    required this.controller,
    required this.label,
    super.key,
  });
  final LocalPhoto photo;
  final PhotoSelectionController controller;
  final String label;
  @override
  Widget build(BuildContext context) {
    final number = controller.number(photo);
    final colors = Theme.of(context).colorScheme;
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      selected: number > 0,
      label: number > 0 ? '$label，已选第 $number 张，取消选择' : '$label，选择',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: tokens.minimumTouchTarget,
        child: IconButton(
          key: ValueKey('photo-select-${photo.id}'),
          onPressed: controller.busy ? null : () => controller.toggle(photo),
          icon: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: number > 0
                  ? colors.primary.withValues(alpha: 0.82)
                  : tokens.panel.withValues(alpha: 0.24),
              border: Border.all(
                color: number > 0 ? colors.primary : tokens.mutedText,
              ),
            ),
            child: number == 0
                ? null
                : Text(
                    '$number',
                    textScaler: TextScaler.noScaling,
                    style: Theme.of(context).textTheme.wenyouUtilityLabel
                        .copyWith(color: colors.onPrimary),
                  ),
          ),
        ),
      ),
    );
  }
}
