import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef IdentityProfilePreviewBuilder =
    Widget Function({
      required String threadId,
      required String postId,
      required ValueChanged<String> onOpenPost,
    });

/// 楼层模块提供自己的只读正文，身份卡只负责位置与关闭导航。
final identityProfilePreviewBuilderProvider =
    Provider<IdentityProfilePreviewBuilder>(
      (ref) => throw StateError('身份资料正文尚未绑定。'),
    );
