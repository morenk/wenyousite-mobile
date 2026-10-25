import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_paste.dart';

Future<Delta> prepareDynamicFontPaste(
  Delta value,
  TextFontService service,
) async {
  final versions = value.operations
      .map((op) => op.attributes?['font'])
      .whereType<String>()
      .toSet();
  if (versions.isNotEmpty) await service.checkPasteVersions(versions);
  return WenyouEditorClipboardPastePlanner.filterFonts(
    value,
    service.canPasteFont,
  );
}
