import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/photo_selection_page.dart';

/// 路由之上的稳定宿主，资料刷新不销毁图库；换号立即关闭并丢弃结果。
class PhotoSelectionHost extends ConsumerStatefulWidget {
  const PhotoSelectionHost({required this.child, super.key});
  final Widget child;
  @override
  ConsumerState<PhotoSelectionHost> createState() => _PhotoSelectionHostState();
}

class _PhotoSelectionHostState extends ConsumerState<PhotoSelectionHost> {
  late final _coordinator = ref.read(photoSelectionCoordinatorProvider);
  Route<List<MediaUploadInput>>? _route;

  @override
  void initState() {
    super.initState();
    _coordinator.presenter = _present;
  }

  Future<List<MediaUploadInput>?> _present(
    PhotoSelectionRequest request,
  ) async {
    final navigator = ref
        .read(appRouterProvider)
        .routerDelegate
        .navigatorKey
        .currentState;
    if (navigator == null || !mounted) return null;
    final scope = ref.read(sessionScopeProvider);
    final library = ref.read(photoLibraryProvider);
    final fallback = SystemEditorImagePicker(ImagePicker());
    final route = wenyouFullscreenRoute<List<MediaUploadInput>>(
      context: navigator.context,
      settings: const RouteSettings(name: 'photoSelection'),
      builder: (_) => PhotoSelectionPage(
        library: library,
        request: request,
        systemPicker: () async {
          if (!mounted || ref.read(sessionScopeProvider) != scope) return [];
          final inputs = request.limit == 1
              ? [?await fallback.pickFromGalleryFor(request.purpose)]
              : await fallback.pickManyFromGalleryFor(
                  limit: request.limit,
                  purpose: request.purpose,
                );
          return mounted && ref.read(sessionScopeProvider) == scope
              ? inputs
              : [];
        },
      ),
    );
    _route = route;
    try {
      final result = await navigator.push(route);
      return mounted && ref.read(sessionScopeProvider) == scope ? result : null;
    } finally {
      if (identical(_route, route)) _route = null;
    }
  }

  void _close() {
    final route = _route;
    if (route != null && route.isActive) route.navigator?.removeRoute(route);
  }

  @override
  void dispose() {
    _coordinator.presenter = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionScopeProvider, (previous, next) {
      if (previous != next) {
        // Riverpod 的切号通知可能发生在树构建期间。
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _close();
        });
      }
    });
    return widget.child;
  }
}
