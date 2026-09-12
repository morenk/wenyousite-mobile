import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import '../../support/block_boundary_fixtures.dart';

void main() {
  final fixture = loadBlockBoundaryFixture();
  final exports = <Map<String, dynamic>>[];
  tearDownAll(() {
    Directory('build').createSync(recursive: true);
    File(
      'build/mobile-block-boundary-serialized.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(exports));
  });
  test('消费明确版本的共享块边界契约', () {
    expect(fixture['version'], 1);
    expect(fixture['markdownContractVersion'], 5);
  });
  for (final item in (fixture['cases'] as List).cast<Map<String, dynamic>>()) {
    test('块边界共享语义 ${item['id']}', () {
      final source = item['markdown'] as String;
      final decoded = MarkdownDeltaCodec.decode(source, imageAlignment: true);
      if (item['supported'] != true) {
        final analysis = MarkdownAlignmentContract.analyze(
          source,
          imageAlignment: true,
        );
        final visible = decoded.delta.operations
            .where((op) => op.data is String)
            .map((op) => op.data)
            .join();
        final sourceLines = source.replaceAll('\r\n', '\n').split('\n');
        for (var i = 0; i < sourceLines.length; i++) {
          if (analysis.validMarkerLines.contains(i)) continue;
          final marker = RegExp(
            r'\[wenyousite-align[^\r\n]*',
          ).firstMatch(sourceLines[i]);
          if (marker != null) expect(visible, contains(marker.group(0)));
        }
        if ((item['id'] as String).startsWith('protected-') ||
            item['id'] == 'raw-html-heading-mobile-regression') {
          expect(analysis.validMarkerLines, isEmpty);
          expect(
            decoded.delta.operations.any(
              (op) => op.attributes?['align'] != null,
            ),
            isFalse,
          );
        }
        for (final op in decoded.delta.operations) {
          final link = op.attributes?['link'];
          if (link != null) {
            expect(
              Uri.parse(link as String).scheme,
              isIn(['http', 'https', 'mailto']),
            );
          }
        }
        expect(decoded.delta.isNotEmpty, isTrue);
        final saved = MarkdownDeltaCodec.encode(
          decoded.delta,
          imageAlignment: true,
        );
        expect(
          boundaryRows(
            MarkdownDeltaCodec.decode(saved, imageAlignment: true).delta,
          ),
          boundaryRows(decoded.delta),
        );
        exports.add({
          'id': item['id'],
          'markdown': saved,
          'editorLines': boundaryRows(
            decoded.delta,
          ).map((row) => row['text']).toList(),
          'editorFallback': 'unsupported-source',
          'expectedBackendAccepted': item['id'] != 'unsafe-target',
          if (item['id'] == 'unsafe-target')
            'expectedError': {'code': 'unsafe-link', 'line': 3},
        });
        return;
      }
      final analysis = MarkdownAlignmentContract.analyze(
        source,
        imageAlignment: true,
      );
      final expectedBlocks = (item['blocks'] as List)
          .cast<Map<String, dynamic>>();
      final expectedAligned = expectedBlocks
          .where((block) => block['markerLine'] != null)
          .toList();
      expect(
        analysis.validMarkerLines,
        expectedAligned.map((b) => b['markerLine']).toSet(),
      );
      for (var i = 0; i < expectedAligned.length; i++) {
        final actual = analysis.blocks[i];
        final expected = expectedAligned[i];
        expect(
          [
            actual.markerLine,
            actual.startLine,
            actual.endLine,
            actual.alignment.name,
          ],
          [
            expected['markerLine'],
            expected['startLine'],
            expected['endLine'],
            expected['alignment'],
          ],
        );
      }
      final rows = boundaryRows(decoded.delta);
      expect(
        rows.map((row) => row['text']).toList(),
        expectedBoundaryEditorLines(item),
      );
      expect(
        rows.map((row) => row['alignment']).toList(),
        item['lineAlignments'],
      );
      final expectedTypes = [
        for (final block in expectedBlocks)
          for (final _ in (block['lines'] as List)) block['type'],
      ];
      expect(rows.map((row) => row['type']).toList(), expectedTypes);
      final saved = MarkdownDeltaCodec.encode(
        decoded.delta,
        imageAlignment: true,
      );
      final reopened = MarkdownDeltaCodec.decode(saved, imageAlignment: true);
      expect(boundaryRows(reopened.delta), rows);
      expect(
        MarkdownDeltaCodec.encode(reopened.delta, imageAlignment: true),
        saved,
      );
      exports.add({
        'id': item['id'],
        'markdown': saved,
        'expectedBackendAccepted': true,
        'editorLines': rows.map((row) => row['text']).toList(),
        if (usesExistingLinkTitleFallback(item['id'] as String))
          'editorFallback': 'existing-link-title-source',
        'lineAlignments': item['lineAlignments'],
      });
    });
  }
}
