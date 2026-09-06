import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';

void invalidateVisibilityCaches(ProviderContainer container) =>
    container.read(contentVisibilityRevisionProvider.notifier).advance();
