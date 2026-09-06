import 'dart:async';

import 'package:wenyousite_mobile/features/thread_feed/application/thread_category_catalog_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/domain/thread_category_presentation.dart';

/// A public catalog has one process cache, independent of account projections.
/// Explicit refreshes bypass age checks but still join the single in-flight load.
class CachedThreadCategoryCatalogRepository
    implements ThreadCategoryCatalogRepository, ThreadCategoryCatalogUpdates {
  CachedThreadCategoryCatalogRepository(
    this._source, {
    this.maxAge = const Duration(minutes: 5),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ThreadCategoryCatalogRepository _source;
  final Duration maxAge;
  final DateTime Function() _now;
  List<ThreadCategory>? _snapshot;
  DateTime? _loadedAt;
  Future<List<ThreadCategory>>? _inFlight;
  final _changes = StreamController<List<ThreadCategory>>.broadcast(sync: true);
  bool _disposed = false;

  @override
  Stream<List<ThreadCategory>> get changes => _changes.stream;

  @override
  Future<List<ThreadCategory>> fetchThreadCategories({bool refresh = false}) {
    final pending = _inFlight;
    if (pending != null) return pending;
    final snapshot = _snapshot;
    final loadedAt = _loadedAt;
    if (!refresh &&
        snapshot != null &&
        loadedAt != null &&
        _now().difference(loadedAt) < maxAge) {
      return Future.value(snapshot);
    }
    return _inFlight = _load().whenComplete(() => _inFlight = null);
  }

  Future<List<ThreadCategory>> _load() async {
    final categories = await _source.fetchThreadCategories(refresh: true);
    final snapshot = List<ThreadCategory>.unmodifiable(categories);
    _snapshot = snapshot;
    _loadedAt = _now();
    if (!_disposed) _changes.add(snapshot);
    return snapshot;
  }

  void dispose() {
    _disposed = true;
    unawaited(_changes.close());
  }
}
