// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_catalog_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontCatalogPageDtoFontVersionEnum _$fontCatalogPageDtoFontVersionEnum_n2 =
    const FontCatalogPageDtoFontVersionEnum._('n2');
const FontCatalogPageDtoFontVersionEnum
_$fontCatalogPageDtoFontVersionEnum_unknownDefaultOpenApi =
    const FontCatalogPageDtoFontVersionEnum._('unknownDefaultOpenApi');

FontCatalogPageDtoFontVersionEnum _$fontCatalogPageDtoFontVersionEnumValueOf(
  String name,
) {
  switch (name) {
    case 'n2':
      return _$fontCatalogPageDtoFontVersionEnum_n2;
    case 'unknownDefaultOpenApi':
      return _$fontCatalogPageDtoFontVersionEnum_unknownDefaultOpenApi;
    default:
      return _$fontCatalogPageDtoFontVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontCatalogPageDtoFontVersionEnum>
_$fontCatalogPageDtoFontVersionEnumValues =
    BuiltSet<FontCatalogPageDtoFontVersionEnum>(
      const <FontCatalogPageDtoFontVersionEnum>[
        _$fontCatalogPageDtoFontVersionEnum_n2,
        _$fontCatalogPageDtoFontVersionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<FontCatalogPageDtoFontVersionEnum>
_$fontCatalogPageDtoFontVersionEnumSerializer =
    _$FontCatalogPageDtoFontVersionEnumSerializer();

class _$FontCatalogPageDtoFontVersionEnumSerializer
    implements PrimitiveSerializer<FontCatalogPageDtoFontVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n2': '2',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '2': 'n2',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[FontCatalogPageDtoFontVersionEnum];
  @override
  final String wireName = 'FontCatalogPageDtoFontVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontCatalogPageDtoFontVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontCatalogPageDtoFontVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontCatalogPageDtoFontVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontCatalogPageDto extends FontCatalogPageDto {
  @override
  final FontCatalogPageDtoFontVersionEnum fontVersion;
  @override
  final String releaseId;
  @override
  final int revision;
  @override
  final BuiltList<FontCatalogEntryDto> items;
  @override
  final String? nextCursor;

  factory _$FontCatalogPageDto([
    void Function(FontCatalogPageDtoBuilder)? updates,
  ]) => (FontCatalogPageDtoBuilder()..update(updates))._build();

  _$FontCatalogPageDto._({
    required this.fontVersion,
    required this.releaseId,
    required this.revision,
    required this.items,
    this.nextCursor,
  }) : super._();
  @override
  FontCatalogPageDto rebuild(
    void Function(FontCatalogPageDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontCatalogPageDtoBuilder toBuilder() =>
      FontCatalogPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontCatalogPageDto &&
        fontVersion == other.fontVersion &&
        releaseId == other.releaseId &&
        revision == other.revision &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fontVersion.hashCode);
    _$hash = $jc(_$hash, releaseId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontCatalogPageDto')
          ..add('fontVersion', fontVersion)
          ..add('releaseId', releaseId)
          ..add('revision', revision)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class FontCatalogPageDtoBuilder
    implements Builder<FontCatalogPageDto, FontCatalogPageDtoBuilder> {
  _$FontCatalogPageDto? _$v;

  FontCatalogPageDtoFontVersionEnum? _fontVersion;
  FontCatalogPageDtoFontVersionEnum? get fontVersion => _$this._fontVersion;
  set fontVersion(FontCatalogPageDtoFontVersionEnum? fontVersion) =>
      _$this._fontVersion = fontVersion;

  String? _releaseId;
  String? get releaseId => _$this._releaseId;
  set releaseId(String? releaseId) => _$this._releaseId = releaseId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  ListBuilder<FontCatalogEntryDto>? _items;
  ListBuilder<FontCatalogEntryDto> get items =>
      _$this._items ??= ListBuilder<FontCatalogEntryDto>();
  set items(ListBuilder<FontCatalogEntryDto>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  FontCatalogPageDtoBuilder() {
    FontCatalogPageDto._defaults(this);
  }

  FontCatalogPageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fontVersion = $v.fontVersion;
      _releaseId = $v.releaseId;
      _revision = $v.revision;
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontCatalogPageDto other) {
    _$v = other as _$FontCatalogPageDto;
  }

  @override
  void update(void Function(FontCatalogPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontCatalogPageDto build() => _build();

  _$FontCatalogPageDto _build() {
    _$FontCatalogPageDto _$result;
    try {
      _$result =
          _$v ??
          _$FontCatalogPageDto._(
            fontVersion: BuiltValueNullFieldError.checkNotNull(
              fontVersion,
              r'FontCatalogPageDto',
              'fontVersion',
            ),
            releaseId: BuiltValueNullFieldError.checkNotNull(
              releaseId,
              r'FontCatalogPageDto',
              'releaseId',
            ),
            revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'FontCatalogPageDto',
              'revision',
            ),
            items: items.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontCatalogPageDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
