import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';

typedef DynamicFontMetadataRead =
    Future<TextFontResponse?> Function(String path, {String? etag});

/// 原子发布目录与可撤回的版本状态；字体字节不存放在这里。
/// 容量有界，负缓存可淘汰；撤回墓碑满时保守拒绝动态呈现而不复活旧值。
class DynamicFontCatalog {
  DynamicFontCatalog({
    required this.read,
    required this.elapsed,
    required this.directory,
    required this.changed,
  });
  final DynamicFontMetadataRead read;
  final Duration Function() elapsed;
  final Directory directory;
  final void Function() changed;
  static const maximumCatalogBytes = 4 * 1024 * 1024;
  static const maximumEntries = 8192;
  static const maximumDescriptors = 256;
  static const maximumTombstones = 4096;
  final _versions = <String, FontVersionDescriptorDto>{};
  final _versionEtags = <String, String>{};
  final _versionDue = <String, Duration>{};
  final _negative = <String, Duration>{};
  final _withdrawn = <String>{};
  final _inflight = <String, Future<void>>{};
  List<FontCatalogEntryDto> _entries = const [];
  String? _etag;
  int _revision = -1;
  Duration _due = Duration.zero;
  bool _denyAll = false;
  Future<void>? _refreshing;
  Future<void>? _restoring;
  Future<void> _saving = Future.value();

  List<FontCatalogEntryDto> get entries => List.unmodifiable(
    _entries.where(
      (entry) =>
          !_denyAll &&
          !_withdrawn.contains(entry.versionId) &&
          (_versions[entry.versionId]?.selectable ?? true),
    ),
  );
  int get revision => _revision;
  bool get hasWithdrawals => _denyAll || _withdrawn.isNotEmpty;
  bool withdrawn(String id) => _denyAll || _withdrawn.contains(id);
  bool unavailable(String id) =>
      withdrawn(id) ||
      !_versions.containsKey(id) &&
          elapsed() < (_negative[id] ?? Duration.zero);
  FontVersionDescriptorDto? descriptor(String id) =>
      withdrawn(id) ? null : _versions[id];
  bool canPaste(String id) => descriptor(id)?.pasteAllowed == true;
  bool canRender(String id) => descriptor(id)?.renderAllowed == true;
  bool canSelect(String id) =>
      entries.any((e) => e.versionId == id) &&
      descriptor(id)?.selectable == true;

  Future<void> restore() => _restoring ??= _restore();
  Future<void> _restore() async {
    try {
      final file = File('${directory.path}/dynamic-catalog.json');
      if (!await file.exists() || await file.length() > 24 * 1024 * 1024) {
        return;
      }
      final value =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      if (value['version'] != 1) return;
      final tombstones = value['withdrawn'] as List;
      if (tombstones.length > maximumTombstones ||
          !tombstones.every(MarkdownTextFont.isVersionId)) {
        return;
      }
      _withdrawn.addAll(tombstones.cast<String>());
      _denyAll = value['denyAll'] == true;
      final rows = value['entries'] as List;
      final versions = value['descriptors'] as List;
      if (rows.length > maximumEntries ||
          versions.length > maximumDescriptors ||
          utf8.encode(jsonEncode(rows)).length > maximumCatalogBytes) {
        return;
      }
      final parsed = rows
          .map((e) => _entry(e as Map<String, dynamic>))
          .toList();
      for (final raw in versions) {
        acceptVersion(_version(raw as Map<String, dynamic>), notify: false);
      }
      _entries = parsed;
      _revision = value['revision'] as int;
      changed();
    } on Object {
      // 缓存故障不创建可信来源，网络重验证仍会继续。
    }
  }

  Future<void> refresh({bool force = false}) {
    if (_refreshing case final pending?) return pending;
    if (!force && elapsed() < _due) return Future.value();
    return _refreshing = _refresh().whenComplete(() => _refreshing = null);
  }

  Future<void> _refresh() async {
    await restore();
    // 409 游标失效最多立即重取一次；持续变动留给外层退避调度。
    for (var restart = 0; restart < 2; restart++) {
      final items = <FontCatalogEntryDto>[];
      final ids = <String>{}, families = <String>{}, cursors = <String>{};
      String? cursor, release, firstEtag;
      int? revision;
      var totalBytes = 0, invalidated = false;
      do {
        final path = Uri(
          path: '/api/v1/meta/text-fonts/v2',
          queryParameters: {'limit': '200', 'cursor': ?cursor},
        ).toString();
        final response = await read(path, etag: cursor == null ? _etag : null);
        if (response == null) return;
        if (response.status == 304 && cursor == null && _etag != null) {
          _due = elapsed() + const Duration(minutes: 5);
          return;
        }
        if (response.status == 409) {
          invalidated = true;
          break;
        }
        if (response.status != 200) return;
        totalBytes += response.bytes.length;
        if (totalBytes > maximumCatalogBytes) {
          throw const FormatException('字体目录过大');
        }
        final data = _data(response.bytes);
        final dto = standardSerializers.deserializeWith(
          FontCatalogPageDto.serializer,
          data,
        )!;
        if (dto.fontVersion.name != 'n2' ||
            !RegExp(r'^tfc_[a-f0-9]{32}$').hasMatch(dto.releaseId) ||
            dto.revision < 0 ||
            dto.items.length > 200 ||
            release != null &&
                (release != dto.releaseId || revision != dto.revision)) {
          throw const FormatException('字体目录分页不一致');
        }
        release ??= dto.releaseId;
        revision ??= dto.revision;
        if (cursor == null) firstEtag = _safeEtag(response.etag);
        for (final item in dto.items) {
          _validateEntry(item);
          if (!ids.add(item.versionId) || !families.add(item.familyId)) {
            throw const FormatException('字体目录包含重复项');
          }
          items.add(item);
        }
        if (items.length > maximumEntries) {
          throw const FormatException('字体目录数量超限');
        }
        cursor = dto.nextCursor;
        if (cursor != null && (cursor.length > 4096 || !cursors.add(cursor))) {
          throw const FormatException('字体目录游标无效');
        }
      } while (cursor != null);
      if (invalidated) continue;
      if (revision! >= _revision) {
        _entries = List.unmodifiable(items);
        _revision = revision;
        _etag = firstEtag;
        _due = elapsed() + const Duration(minutes: 5);
        changed();
        await _save();
      }
      return;
    }
  }

  Future<void> ensureVersion(String id, {bool force = false}) {
    if (!MarkdownTextFont.isVersionId(id) || withdrawn(id)) {
      return Future.value();
    }
    if (_inflight[id] case final pending?) return pending;
    if (_inflight.length >= maximumDescriptors ||
        !force && elapsed() < (_versionDue[id] ?? Duration.zero) ||
        elapsed() < (_negative[id] ?? Duration.zero)) {
      return Future.value();
    }
    return _inflight[id] = _loadVersion(id).whenComplete(() {
      _inflight.remove(id);
    });
  }

  Future<void> _loadVersion(String id) async {
    final response = await read(
      '/api/v1/meta/text-fonts/v2/versions/$id',
      etag: _versionEtags[id],
    );
    if (response == null) return;
    if (response.status == 404) {
      _negative.remove(id);
      _negative[id] = elapsed() + const Duration(seconds: 30);
      while (_negative.length > maximumDescriptors) {
        _negative.remove(_negative.keys.first);
      }
      return;
    }
    if (response.status == 410) {
      markWithdrawn(id);
      await _save();
      return;
    }
    if (response.status == 304 && _versions.containsKey(id)) {
      _versionDue[id] = elapsed() + const Duration(minutes: 5);
      return;
    }
    if (response.status != 200) return;
    final dto = _version(_data(response.bytes));
    if (dto.versionId != id) throw const FormatException('字体版本身份不符');
    acceptVersion(dto);
    if (!withdrawn(id) && identical(_versions[id], dto)) {
      final etag = _safeEtag(response.etag);
      if (etag != null) _versionEtags[id] = etag;
      _versionDue[id] = elapsed() + const Duration(minutes: 5);
    }
    await _save();
  }

  void acceptVersion(FontVersionDescriptorDto dto, {bool notify = true}) {
    _validateVersion(dto);
    if (dto.status.name == 'withdrawn') {
      markWithdrawn(dto.versionId, notify: notify);
      return;
    }
    if (withdrawn(dto.versionId) ||
        dto.revision < (_versions[dto.versionId]?.revision ?? -1)) {
      return;
    }
    final previous = _versions[dto.versionId];
    if (previous != null &&
        (previous.familyId != dto.familyId ||
            previous.versionNumber != dto.versionNumber ||
            previous.manifest != dto.manifest ||
            previous.specimen != dto.specimen ||
            previous.assetBasePath != dto.assetBasePath)) {
      throw const FormatException('已发布字体版本的资源不可变');
    }
    _versions.remove(dto.versionId);
    _versions[dto.versionId] = dto;
    _negative.remove(dto.versionId);
    while (_versions.length > maximumDescriptors) {
      final first = _versions.keys.first;
      _versions.remove(first);
      _versionDue.remove(first);
      _versionEtags.remove(first);
    }
    if (notify) changed();
  }

  void markWithdrawn(String id, {bool notify = true}) {
    if (!MarkdownTextFont.isVersionId(id)) return;
    if (!_withdrawn.contains(id) && _withdrawn.length >= maximumTombstones) {
      _denyAll = true;
    } else {
      _withdrawn.add(id);
    }
    _versions.remove(id);
    _versionDue.remove(id);
    _versionEtags.remove(id);
    if (notify) changed();
  }

  Future<void> persist() => _save();
  Future<void> _save() => _saving = _saving.then((_) async {
    try {
      await directory.create(recursive: true);
      final value = jsonEncode({
        'version': 1,
        'revision': _revision,
        'denyAll': _denyAll,
        'withdrawn': _withdrawn.toList(),
        'entries': _entries
            .map(
              (e) => standardSerializers.serializeWith(
                FontCatalogEntryDto.serializer,
                e,
              ),
            )
            .toList(),
        'descriptors': _versions.values
            .map(
              (e) => standardSerializers.serializeWith(
                FontVersionDescriptorDto.serializer,
                e,
              ),
            )
            .toList(),
      });
      if (utf8.encode(value).length > 24 * 1024 * 1024) return;
      final file = File('${directory.path}/dynamic-catalog.json');
      final temporary = File('${file.path}.partial');
      await temporary.writeAsString(value, flush: true);
      await temporary.rename(file.path);
    } on FileSystemException {
      /* 保留当前进程状态，缓存不可写不回退到旧值。 */
    }
  });

  static String? _safeEtag(String? value) =>
      value != null &&
          value.length <= 4096 &&
          !value.contains(RegExp(r'[\r\n]'))
      ? value
      : null;
  static Map<String, dynamic> _data(Uint8List bytes) {
    if (bytes.length > 65536) throw const FormatException('字体元数据超限');
    final value = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    if (value['code'] != 0) throw const FormatException('字体元数据失败');
    return value['data'] as Map<String, dynamic>;
  }

  static FontCatalogEntryDto _entry(Map<String, dynamic> raw) {
    final dto = standardSerializers.deserializeWith(
      FontCatalogEntryDto.serializer,
      raw,
    )!;
    _validateEntry(dto);
    return dto;
  }

  static void _validateEntry(FontCatalogEntryDto dto) {
    if (!MarkdownTextFont.isVersionId(dto.versionId) ||
        !RegExp(r'^tff_[a-f0-9]{32}$').hasMatch(dto.familyId) ||
        dto.name.isEmpty ||
        dto.name.length > 80 ||
        !const {'zh', 'ja', 'en', 'other'}.contains(dto.designLanguage.name) ||
        !dto.selectable ||
        !dto.pasteAllowed ||
        !dto.renderAllowed) {
      throw const FormatException('无效目录项');
    }
    dynamicFontAsset(
      dto.versionId,
      dto.assetBasePath,
      dto.specimen,
      formats: {'png'},
    );
  }

  static FontVersionDescriptorDto _version(Map<String, dynamic> raw) {
    final dto = standardSerializers.deserializeWith(
      FontVersionDescriptorDto.serializer,
      raw,
    )!;
    _validateVersion(dto);
    return dto;
  }

  static void _validateVersion(FontVersionDescriptorDto dto) {
    if (!MarkdownTextFont.isVersionId(dto.versionId) ||
        dto.revision < 0 ||
        dto.versionNumber < 1 ||
        dto.fontVersion.name != 'n2' ||
        !RegExp(r'^tff_[a-f0-9]{32}$').hasMatch(dto.familyId) ||
        dto.name.isEmpty ||
        dto.name.length > 80 ||
        !const {'zh', 'ja', 'en', 'other'}.contains(dto.designLanguage.name) ||
        !const {
          'published',
          'disabled',
          'withdrawn',
        }.contains(dto.status.name)) {
      throw const FormatException('无效字体版本');
    }
    if (dto.status.name == 'withdrawn') {
      if (dto.renderAllowed ||
          dto.pasteAllowed ||
          dto.selectable ||
          dto.manifest != null ||
          dto.specimen != null ||
          dto.assetBasePath != null) {
        throw const FormatException('撤回墓碑无效');
      }
      return;
    }
    if (!dto.renderAllowed ||
        dto.manifest == null ||
        dto.specimen == null ||
        dto.assetBasePath == null ||
        dto.status.name == 'disabled' && (dto.selectable || dto.pasteAllowed) ||
        dto.status.name == 'published' && !dto.pasteAllowed) {
      throw const FormatException('字体状态不一致');
    }
    dynamicFontAsset(
      dto.versionId,
      dto.assetBasePath!,
      dto.manifest!,
      formats: {'json'},
      maximumBytes: 4 * 1024 * 1024,
    );
    dynamicFontAsset(
      dto.versionId,
      dto.assetBasePath!,
      dto.specimen!,
      formats: {'png'},
    );
  }
}
