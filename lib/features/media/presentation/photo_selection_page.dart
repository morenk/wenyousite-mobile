import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_progress_ring.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_retry_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/application/photo_selection_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/local_photo_thumbnail.dart';
import 'package:wenyousite_mobile/features/media/presentation/photo_selection_preview.dart';

class PhotoSelectionPage extends StatefulWidget {
  const PhotoSelectionPage({
    required this.library,
    required this.request,
    required this.systemPicker,
    super.key,
  });
  final PhotoLibrary library;
  final PhotoSelectionRequest request;
  final Future<List<MediaUploadInput>> Function() systemPicker;

  @override
  State<PhotoSelectionPage> createState() => _PhotoSelectionPageState();
}

class _PhotoSelectionPageState extends State<PhotoSelectionPage>
    with WidgetsBindingObserver {
  late final _controller = PhotoSelectionController(
    library: widget.library,
    request: widget.request,
  );
  final _scroll = ScrollController();
  bool _albumsOpen = false;
  bool _systemBusy = false;
  bool _permissionBusy = false;
  List<LocalPhoto>? _preview;
  int _previewIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scroll.addListener(_onScroll);
    unawaited(_refresh(requestPermission: true));
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600 && _controller.pageError == null) {
      unawaited(_controller.loadMore());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_systemBusy &&
        !_permissionBusy) {
      unawaited(_refresh());
    }
  }

  Future<void> _refresh({
    bool requestPermission = false,
    bool selectMore = false,
  }) async {
    if (_permissionBusy || _systemBusy || _controller.busy) return;
    _permissionBusy = true;
    // 重新核验权限前关闭可能持有旧授权缩略图的预览。
    if (mounted && (_preview != null || _albumsOpen)) {
      setState(() {
        _preview = null;
        _albumsOpen = false;
      });
    }
    try {
      await _controller.refresh(
        requestPermission: requestPermission,
        selectMore: selectMore,
      );
    } finally {
      _permissionBusy = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final result = await _controller.confirm();
    if (mounted && result != null) Navigator.of(context).pop(result);
  }

  Future<void> _openSettings() async {
    try {
      await widget.library.openSettings();
    } on Object {
      if (mounted) showWenyouSnackBar(context, '打开设置失败，请重试。');
    }
  }

  Future<void> _system() async {
    if (_systemBusy || _controller.busy) return;
    setState(() => _systemBusy = true);
    try {
      final inputs = await widget.systemPicker();
      if (mounted && inputs.isNotEmpty) {
        Navigator.of(context).pop(inputs.take(widget.request.limit).toList());
      }
    } on Object {
      if (mounted) showWenyouSnackBar(context, '选择图片失败，请重试。');
    } finally {
      if (mounted) setState(() => _systemBusy = false);
    }
  }

  void _openPreview(List<LocalPhoto> photos, int index) {
    setState(() {
      _preview = List.of(photos);
      _previewIndex = index;
      _albumsOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      final state = _controller;
      final busy = state.busy || _systemBusy;
      final tokens = context.wenyouTokens;
      final preview = _preview;
      return PopScope<Object?>(
        canPop: preview == null && !_albumsOpen,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            setState(() {
              _preview = null;
              _albumsOpen = false;
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: preview == null ? '取消选择' : '返回相册',
              onPressed: () {
                if (preview != null || _albumsOpen) {
                  setState(() {
                    _preview = null;
                    _albumsOpen = false;
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: const WenyouIcon(WenyouIconIds.actionClose),
            ),
            title: preview != null
                ? Text('${_previewIndex + 1} / ${preview.length}')
                : TextButton(
                    key: const Key('photo-album-dropdown'),
                    onPressed: busy || state.albums.isEmpty
                        ? null
                        : () => setState(() => _albumsOpen = !_albumsOpen),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            state.album?.name ?? '最近图片',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        WenyouIcon(
                          _albumsOpen
                              ? WenyouIconIds.navigationCollapse
                              : WenyouIconIds.navigationExpand,
                        ),
                      ],
                    ),
                  ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              if (state.access == PhotoLibraryAccess.limited)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const Key('photo-select-more'),
                    onPressed: busy ? null : () => _refresh(selectMore: true),
                    child: const Text('选择更多照片'),
                  ),
                ),
              if (state.error != null)
                Padding(
                  padding: EdgeInsets.all(tokens.space8),
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (preview != null && state.accessible)
                      PhotoSelectionPreview(
                        key: ObjectKey(preview),
                        photos: preview,
                        initialIndex: _previewIndex,
                        controller: state,
                        onPageChanged: (index) =>
                            setState(() => _previewIndex = index),
                      )
                    else
                      _libraryBody(state),
                    if (_albumsOpen) _albumList(state),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(tokens.space12),
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: tokens.space8,
                overflowSpacing: tokens.space8,
                children: [
                  TextButton(
                    key: const Key('photo-preview-selected'),
                    onPressed: busy || state.selected.isEmpty
                        ? null
                        : () => _openPreview(state.selected, 0),
                    child: const Text('预览已选'),
                  ),
                  FilledButton(
                    key: const Key('photo-confirm'),
                    onPressed: busy || state.selected.isEmpty ? null : _confirm,
                    child: state.confirming || _systemBusy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: WenyouProgressRing(),
                          )
                        : Text('确定（${state.selected.length}）'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _libraryBody(PhotoSelectionController state) {
    if (state.loading || _systemBusy) {
      return const Center(child: WenyouProgressRing());
    }
    if (!state.accessible && state.access != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('允许读取照片后可浏览相册。'),
              TextButton(
                key: const Key('photo-request-permission'),
                onPressed: () => _refresh(requestPermission: true),
                child: const Text('允许读取照片'),
              ),
              TextButton(
                key: const Key('photo-open-settings'),
                onPressed: _openSettings,
                child: const Text('打开设置'),
              ),
              FilledButton(
                key: const Key('photo-system-picker'),
                onPressed: _system,
                child: const Text('使用系统选择'),
              ),
            ],
          ),
        ),
      );
    }
    if (state.error != null && state.photos.isEmpty) {
      return Center(
        child: TextButton(onPressed: _refresh, child: const Text('重新加载')),
      );
    }
    if (state.photos.isEmpty && state.loadingPage) {
      return const Center(child: WenyouProgressRing());
    }
    return CustomScrollView(
      key: const Key('photo-grid-scroll'),
      controller: _scroll,
      slivers: [
        if (state.photos.isEmpty && state.pageError == null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('相册中没有图片'),
                  TextButton(onPressed: _refresh, child: const Text('刷新')),
                ],
              ),
            ),
          ),
        SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: context.wenyouTokens.space4,
            crossAxisSpacing: context.wenyouTokens.space4,
          ),
          itemCount: state.photos.length,
          itemBuilder: (context, index) {
            final photo = state.photos[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Semantics(
                  button: true,
                  label: '预览第 ${index + 1} 张图片',
                  child: GestureDetector(
                    onTap: state.busy
                        ? null
                        : () => _openPreview(state.photos, index),
                    child: LocalPhotoThumbnail(
                      library: widget.library,
                      photo: photo,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PhotoSelectionMark(
                    photo: photo,
                    controller: state,
                    label: '第 ${index + 1} 张图片',
                  ),
                ),
              ],
            );
          },
        ),
        if (state.pageError != null)
          SliverToBoxAdapter(
            child: WenyouRetryFailure(
              failure: null,
              title: '加载失败',
              message: '',
              inline: true,
              onRetry: state.loadMore,
            ),
          )
        else
          SliverToBoxAdapter(
            child: WenyouPaginationFooter(
              hasMore: state.hasMore,
              isLoading: state.loadingPage,
              onLoadMore: state.loadMore,
            ),
          ),
      ],
    );
  }

  Widget _albumList(PhotoSelectionController state) => Material(
    color: context.wenyouTokens.panel,
    child: ListView.builder(
      key: const Key('photo-albums'),
      itemCount: state.albums.length,
      itemBuilder: (context, index) {
        final album = state.albums[index];
        return ListTile(
          key: ValueKey('photo-album-${album.id}'),
          leading: SizedBox.square(
            dimension: context.wenyouTokens.minimumTouchTarget,
            child: album.cover == null
                ? const SizedBox.shrink()
                : LocalPhotoThumbnail(
                    library: widget.library,
                    photo: album.cover!,
                  ),
          ),
          title: Text(album.name),
          subtitle: Text('${album.count}'),
          selected: album.id == state.album?.id,
          trailing: album.id == state.album?.id
              ? const WenyouIcon(WenyouIconIds.actionConfirm)
              : null,
          onTap: () {
            setState(() => _albumsOpen = false);
            if (_scroll.hasClients) _scroll.jumpTo(0);
            unawaited(state.switchAlbum(album));
          },
        );
      },
    ),
  );
}
