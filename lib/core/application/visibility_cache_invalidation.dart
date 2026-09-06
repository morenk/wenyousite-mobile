import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Blocking changes the viewer's access to every cached content projection.
/// The composition root clears readers while keeping editor drafts intact.
final visibilityCacheInvalidatorProvider = Provider<void Function()>(
  (ref) => () {},
);
