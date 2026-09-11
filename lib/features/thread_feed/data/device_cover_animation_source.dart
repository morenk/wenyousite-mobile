import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cached_cover_animation_source.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cover_animation_disk_store.dart';

final deviceCoverAnimationSourceProvider = Provider<CoverAnimationSource>((
  ref,
) {
  final source = CachedCoverAnimationSource(
    disk: CoverAnimationDiskStore(
      directory: () async {
        final root = await getApplicationCacheDirectory();
        return Directory('${root.path}/wenyou-cover-animation-v1');
      },
    ),
  );
  ref.onDispose(source.dispose);
  return source;
});
