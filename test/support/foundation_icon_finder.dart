import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

Finder findFoundationIcon(String semanticId) {
  return find.byWidgetPredicate(
    (widget) => widget is WenyouIcon && widget.semanticId == semanticId,
    description: 'Foundation icon $semanticId',
  );
}
