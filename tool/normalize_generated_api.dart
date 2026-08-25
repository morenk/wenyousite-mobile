import 'dart:io';

const _generatedPackage = 'packages/wenyou_api';

Future<void> main() async {
  final pubspec = File('$_generatedPackage/pubspec.yaml');
  final ignoreFile = File('$_generatedPackage/.gitignore');
  final analysisOptions = File('$_generatedPackage/analysis_options.yaml');

  if (!pubspec.existsSync() || !ignoreFile.existsSync()) {
    stderr.writeln('请先运行 OpenAPI Generator 生成 $_generatedPackage。');
    exitCode = 1;
    return;
  }

  var pubspecText = pubspec.readAsStringSync();
  final sdkConstraint = RegExp(r"sdk: '>=2\.18\.0 <4\.0\.0'");
  if (!sdkConstraint.hasMatch(pubspecText) &&
      !pubspecText.contains("sdk: '>=3.8.0 <4.0.0'")) {
    stderr.writeln('生成的 pubspec SDK 约束发生未知变化，请审查生成器升级。');
    exitCode = 1;
    return;
  }
  pubspecText = pubspecText.replaceFirst(
    sdkConstraint,
    "sdk: '>=3.8.0 <4.0.0'",
  );
  await _writeGeneratedText(pubspec, pubspecText);

  var ignoreText = ignoreFile.readAsStringSync();
  ignoreText = ignoreText.replaceFirst(
    RegExp(
      r'\n# Don.t commit pubspec lock file\n'
      r'# \(Library packages only! Remove pattern if developing an application package\)\n'
      r'pubspec\.lock\n',
    ),
    '\n# 此生成包随应用发布，提交锁文件以固定代码生成工具链。\n',
  );
  await _writeGeneratedText(ignoreFile, ignoreText);

  var analysisText = analysisOptions.readAsStringSync();
  if (!analysisText.contains('    unused_import: ignore')) {
    analysisText = analysisText.replaceFirst(
      '    deprecated_member_use_from_same_package: ignore\n',
      '    deprecated_member_use_from_same_package: ignore\n'
          '    unused_import: ignore\n',
    );
    await _writeGeneratedText(analysisOptions, analysisText);
  }

  // 从 json_serializable 切换到 built_value 后，生成器不会主动删除旧辅助文件。
  // 路径是固定、可复现的生成产物，必须在每次生成时清理，避免被 analyzer 扫描。
  final staleJsonSerializableHelper = File(
    '$_generatedPackage/lib/src/deserialize.dart',
  );
  if (staleJsonSerializableHelper.existsSync()) {
    staleJsonSerializableHelper.deleteSync();
  }

  final modelDirectory = Directory('$_generatedPackage/lib/src/model');
  for (final entity in modelDirectory.listSync()) {
    if (entity is! File ||
        !entity.path.endsWith('.dart') ||
        entity.path.endsWith('.g.dart') ||
        entity.uri.pathSegments.last == 'api_success_envelope.dart') {
      continue;
    }
    var source = entity.readAsStringSync();
    if (!source.contains('ApiSuccessEnvelopeCodeEnum') ||
        source.contains("model/api_success_envelope.dart';")) {
      continue;
    }
    const anchor = '// ignore_for_file: unused_element\n';
    if (!source.contains(anchor)) {
      stderr.writeln('无法归一化共享成功码 import：${entity.path}');
      exitCode = 1;
      return;
    }
    source = source.replaceFirst(
      anchor,
      "${anchor}import 'package:wenyou_api/src/model/api_success_envelope.dart';\n",
    );
    await _writeGeneratedText(entity, source);
  }

  await _normalizeGeneratedText();
}

Future<void> _normalizeGeneratedText() async {
  final generatedDirectory = Directory(_generatedPackage);
  const textExtensions = {'.dart', '.md', '.yaml', '.yml'};

  for (final entity in generatedDirectory.listSync(recursive: true)) {
    if (entity is! File ||
        entity.path.contains(
          '${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}',
        )) {
      continue;
    }
    final name = entity.uri.pathSegments.last;
    final isKnownText =
        textExtensions.any(name.endsWith) || name == '.gitignore';
    if (!isKnownText) {
      continue;
    }

    final source = entity.readAsStringSync();
    final normalized = source
        .replaceAll(RegExp(r'[ \t]+$', multiLine: true), '')
        .replaceFirst(RegExp(r'\s*$'), '\n');
    if (source != normalized) {
      await _writeGeneratedText(entity, normalized);
    }
  }
}

Future<void> _writeGeneratedText(File file, String contents) async {
  const windowsUserMappedSectionError = 1224;
  // Windows can retain the mapped section for several seconds after the Java
  // generator exits. Keep the bound finite so a persistent lock still fails.
  const maximumAttempts = 100;
  for (var attempt = 1; attempt <= maximumAttempts; attempt++) {
    try {
      file.writeAsStringSync(contents);
      return;
    } on FileSystemException catch (error) {
      final canRetry =
          Platform.isWindows &&
          error.osError?.errorCode == windowsUserMappedSectionError &&
          attempt < maximumAttempts;
      if (!canRetry) rethrow;
      // The Java generator or an on-access scanner can briefly retain a
      // mapped section after generation. Retry only that Windows condition.
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}
