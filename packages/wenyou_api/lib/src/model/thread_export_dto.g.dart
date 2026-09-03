// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_export_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadExportDtoFormatEnum _$threadExportDtoFormatEnum_TXT =
    const ThreadExportDtoFormatEnum._('TXT');
const ThreadExportDtoFormatEnum _$threadExportDtoFormatEnum_MARKDOWN =
    const ThreadExportDtoFormatEnum._('MARKDOWN');
const ThreadExportDtoFormatEnum _$threadExportDtoFormatEnum_BOTH =
    const ThreadExportDtoFormatEnum._('BOTH');
const ThreadExportDtoFormatEnum
_$threadExportDtoFormatEnum_unknownDefaultOpenApi =
    const ThreadExportDtoFormatEnum._('unknownDefaultOpenApi');

ThreadExportDtoFormatEnum _$threadExportDtoFormatEnumValueOf(String name) {
  switch (name) {
    case 'TXT':
      return _$threadExportDtoFormatEnum_TXT;
    case 'MARKDOWN':
      return _$threadExportDtoFormatEnum_MARKDOWN;
    case 'BOTH':
      return _$threadExportDtoFormatEnum_BOTH;
    case 'unknownDefaultOpenApi':
      return _$threadExportDtoFormatEnum_unknownDefaultOpenApi;
    default:
      return _$threadExportDtoFormatEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadExportDtoFormatEnum> _$threadExportDtoFormatEnumValues =
    BuiltSet<ThreadExportDtoFormatEnum>(const <ThreadExportDtoFormatEnum>[
      _$threadExportDtoFormatEnum_TXT,
      _$threadExportDtoFormatEnum_MARKDOWN,
      _$threadExportDtoFormatEnum_BOTH,
      _$threadExportDtoFormatEnum_unknownDefaultOpenApi,
    ]);

Serializer<ThreadExportDtoFormatEnum> _$threadExportDtoFormatEnumSerializer =
    _$ThreadExportDtoFormatEnumSerializer();

class _$ThreadExportDtoFormatEnumSerializer
    implements PrimitiveSerializer<ThreadExportDtoFormatEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'TXT': 'TXT',
    'MARKDOWN': 'MARKDOWN',
    'BOTH': 'BOTH',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'TXT': 'TXT',
    'MARKDOWN': 'MARKDOWN',
    'BOTH': 'BOTH',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ThreadExportDtoFormatEnum];
  @override
  final String wireName = 'ThreadExportDtoFormatEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadExportDtoFormatEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadExportDtoFormatEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadExportDtoFormatEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadExportDto extends ThreadExportDto {
  @override
  final ThreadExportDtoFormatEnum? format;
  @override
  final bool? includeAuthors;
  @override
  final bool? includeTimestamps;
  @override
  final bool? includeFloorNumbers;
  @override
  final bool? includeReplyTargets;
  @override
  final bool? includeSourceLinks;
  @override
  final bool? includeMedia;

  factory _$ThreadExportDto([void Function(ThreadExportDtoBuilder)? updates]) =>
      (ThreadExportDtoBuilder()..update(updates))._build();

  _$ThreadExportDto._({
    this.format,
    this.includeAuthors,
    this.includeTimestamps,
    this.includeFloorNumbers,
    this.includeReplyTargets,
    this.includeSourceLinks,
    this.includeMedia,
  }) : super._();
  @override
  ThreadExportDto rebuild(void Function(ThreadExportDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ThreadExportDtoBuilder toBuilder() => ThreadExportDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadExportDto &&
        format == other.format &&
        includeAuthors == other.includeAuthors &&
        includeTimestamps == other.includeTimestamps &&
        includeFloorNumbers == other.includeFloorNumbers &&
        includeReplyTargets == other.includeReplyTargets &&
        includeSourceLinks == other.includeSourceLinks &&
        includeMedia == other.includeMedia;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, format.hashCode);
    _$hash = $jc(_$hash, includeAuthors.hashCode);
    _$hash = $jc(_$hash, includeTimestamps.hashCode);
    _$hash = $jc(_$hash, includeFloorNumbers.hashCode);
    _$hash = $jc(_$hash, includeReplyTargets.hashCode);
    _$hash = $jc(_$hash, includeSourceLinks.hashCode);
    _$hash = $jc(_$hash, includeMedia.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadExportDto')
          ..add('format', format)
          ..add('includeAuthors', includeAuthors)
          ..add('includeTimestamps', includeTimestamps)
          ..add('includeFloorNumbers', includeFloorNumbers)
          ..add('includeReplyTargets', includeReplyTargets)
          ..add('includeSourceLinks', includeSourceLinks)
          ..add('includeMedia', includeMedia))
        .toString();
  }
}

class ThreadExportDtoBuilder
    implements Builder<ThreadExportDto, ThreadExportDtoBuilder> {
  _$ThreadExportDto? _$v;

  ThreadExportDtoFormatEnum? _format;
  ThreadExportDtoFormatEnum? get format => _$this._format;
  set format(ThreadExportDtoFormatEnum? format) => _$this._format = format;

  bool? _includeAuthors;
  bool? get includeAuthors => _$this._includeAuthors;
  set includeAuthors(bool? includeAuthors) =>
      _$this._includeAuthors = includeAuthors;

  bool? _includeTimestamps;
  bool? get includeTimestamps => _$this._includeTimestamps;
  set includeTimestamps(bool? includeTimestamps) =>
      _$this._includeTimestamps = includeTimestamps;

  bool? _includeFloorNumbers;
  bool? get includeFloorNumbers => _$this._includeFloorNumbers;
  set includeFloorNumbers(bool? includeFloorNumbers) =>
      _$this._includeFloorNumbers = includeFloorNumbers;

  bool? _includeReplyTargets;
  bool? get includeReplyTargets => _$this._includeReplyTargets;
  set includeReplyTargets(bool? includeReplyTargets) =>
      _$this._includeReplyTargets = includeReplyTargets;

  bool? _includeSourceLinks;
  bool? get includeSourceLinks => _$this._includeSourceLinks;
  set includeSourceLinks(bool? includeSourceLinks) =>
      _$this._includeSourceLinks = includeSourceLinks;

  bool? _includeMedia;
  bool? get includeMedia => _$this._includeMedia;
  set includeMedia(bool? includeMedia) => _$this._includeMedia = includeMedia;

  ThreadExportDtoBuilder() {
    ThreadExportDto._defaults(this);
  }

  ThreadExportDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _format = $v.format;
      _includeAuthors = $v.includeAuthors;
      _includeTimestamps = $v.includeTimestamps;
      _includeFloorNumbers = $v.includeFloorNumbers;
      _includeReplyTargets = $v.includeReplyTargets;
      _includeSourceLinks = $v.includeSourceLinks;
      _includeMedia = $v.includeMedia;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadExportDto other) {
    _$v = other as _$ThreadExportDto;
  }

  @override
  void update(void Function(ThreadExportDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadExportDto build() => _build();

  _$ThreadExportDto _build() {
    final _$result =
        _$v ??
        _$ThreadExportDto._(
          format: format,
          includeAuthors: includeAuthors,
          includeTimestamps: includeTimestamps,
          includeFloorNumbers: includeFloorNumbers,
          includeReplyTargets: includeReplyTargets,
          includeSourceLinks: includeSourceLinks,
          includeMedia: includeMedia,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
