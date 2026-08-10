import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ProfileCacheInvalidator = void Function(String? userId);

/// Composition hook for mutations that affect profile projections.
///
/// Features publish the invalidation intent without importing another
/// feature's concrete providers. The application root wires the consumers.
final profileCacheInvalidatorProvider = Provider<ProfileCacheInvalidator>(
  (ref) => (_) {},
);
