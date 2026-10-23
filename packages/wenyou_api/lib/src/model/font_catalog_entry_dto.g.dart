// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_catalog_entry_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontCatalogEntryDtoDesignLanguageEnum
_$fontCatalogEntryDtoDesignLanguageEnum_zh =
    const FontCatalogEntryDtoDesignLanguageEnum._('zh');
const FontCatalogEntryDtoDesignLanguageEnum
_$fontCatalogEntryDtoDesignLanguageEnum_ja =
    const FontCatalogEntryDtoDesignLanguageEnum._('ja');
const FontCatalogEntryDtoDesignLanguageEnum
_$fontCatalogEntryDtoDesignLanguageEnum_en =
    const FontCatalogEntryDtoDesignLanguageEnum._('en');
const FontCatalogEntryDtoDesignLanguageEnum
_$fontCatalogEntryDtoDesignLanguageEnum_other =
    const FontCatalogEntryDtoDesignLanguageEnum._('other');
const FontCatalogEntryDtoDesignLanguageEnum
_$fontCatalogEntryDtoDesignLanguageEnum_unknownDefaultOpenApi =
    const FontCatalogEntryDtoDesignLanguageEnum._('unknownDefaultOpenApi');

FontCatalogEntryDtoDesignLanguageEnum
_$fontCatalogEntryDtoDesignLanguageEnumValueOf(String name) {
  switch (name) {
    case 'zh':
      return _$fontCatalogEntryDtoDesignLanguageEnum_zh;
    case 'ja':
      return _$fontCatalogEntryDtoDesignLanguageEnum_ja;
    case 'en':
      return _$fontCatalogEntryDtoDesignLanguageEnum_en;
    case 'other':
      return _$fontCatalogEntryDtoDesignLanguageEnum_other;
    case 'unknownDefaultOpenApi':
      return _$fontCatalogEntryDtoDesignLanguageEnum_unknownDefaultOpenApi;
    default:
      return _$fontCatalogEntryDtoDesignLanguageEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontCatalogEntryDtoDesignLanguageEnum>
_$fontCatalogEntryDtoDesignLanguageEnumValues =
    BuiltSet<FontCatalogEntryDtoDesignLanguageEnum>(
      const <FontCatalogEntryDtoDesignLanguageEnum>[
        _$fontCatalogEntryDtoDesignLanguageEnum_zh,
        _$fontCatalogEntryDtoDesignLanguageEnum_ja,
        _$fontCatalogEntryDtoDesignLanguageEnum_en,
        _$fontCatalogEntryDtoDesignLanguageEnum_other,
        _$fontCatalogEntryDtoDesignLanguageEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<FontCatalogEntryDtoDesignLanguageEnum>
_$fontCatalogEntryDtoDesignLanguageEnumSerializer =
    _$FontCatalogEntryDtoDesignLanguageEnumSerializer();

class _$FontCatalogEntryDtoDesignLanguageEnumSerializer
    implements PrimitiveSerializer<FontCatalogEntryDtoDesignLanguageEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'zh': 'zh',
    'ja': 'ja',
    'en': 'en',
    'other': 'other',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'zh': 'zh',
    'ja': 'ja',
    'en': 'en',
    'other': 'other',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    FontCatalogEntryDtoDesignLanguageEnum,
  ];
  @override
  final String wireName = 'FontCatalogEntryDtoDesignLanguageEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontCatalogEntryDtoDesignLanguageEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontCatalogEntryDtoDesignLanguageEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontCatalogEntryDtoDesignLanguageEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontCatalogEntryDto extends FontCatalogEntryDto {
  @override
  final String familyId;
  @override
  final String versionId;
  @override
  final String name;
  @override
  final FontCatalogEntryDtoDesignLanguageEnum designLanguage;
  @override
  final int sortOrder;
  @override
  final bool selectable;
  @override
  final bool pasteAllowed;
  @override
  final bool renderAllowed;
  @override
  final String assetBasePath;
  @override
  final FontAssetDto specimen;

  factory _$FontCatalogEntryDto([
    void Function(FontCatalogEntryDtoBuilder)? updates,
  ]) => (FontCatalogEntryDtoBuilder()..update(updates))._build();

  _$FontCatalogEntryDto._({
    required this.familyId,
    required this.versionId,
    required this.name,
    required this.designLanguage,
    required this.sortOrder,
    required this.selectable,
    required this.pasteAllowed,
    required this.renderAllowed,
    required this.assetBasePath,
    required this.specimen,
  }) : super._();
  @override
  FontCatalogEntryDto rebuild(
    void Function(FontCatalogEntryDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontCatalogEntryDtoBuilder toBuilder() =>
      FontCatalogEntryDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontCatalogEntryDto &&
        familyId == other.familyId &&
        versionId == other.versionId &&
        name == other.name &&
        designLanguage == other.designLanguage &&
        sortOrder == other.sortOrder &&
        selectable == other.selectable &&
        pasteAllowed == other.pasteAllowed &&
        renderAllowed == other.renderAllowed &&
        assetBasePath == other.assetBasePath &&
        specimen == other.specimen;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, familyId.hashCode);
    _$hash = $jc(_$hash, versionId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, designLanguage.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, selectable.hashCode);
    _$hash = $jc(_$hash, pasteAllowed.hashCode);
    _$hash = $jc(_$hash, renderAllowed.hashCode);
    _$hash = $jc(_$hash, assetBasePath.hashCode);
    _$hash = $jc(_$hash, specimen.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontCatalogEntryDto')
          ..add('familyId', familyId)
          ..add('versionId', versionId)
          ..add('name', name)
          ..add('designLanguage', designLanguage)
          ..add('sortOrder', sortOrder)
          ..add('selectable', selectable)
          ..add('pasteAllowed', pasteAllowed)
          ..add('renderAllowed', renderAllowed)
          ..add('assetBasePath', assetBasePath)
          ..add('specimen', specimen))
        .toString();
  }
}

class FontCatalogEntryDtoBuilder
    implements Builder<FontCatalogEntryDto, FontCatalogEntryDtoBuilder> {
  _$FontCatalogEntryDto? _$v;

  String? _familyId;
  String? get familyId => _$this._familyId;
  set familyId(String? familyId) => _$this._familyId = familyId;

  String? _versionId;
  String? get versionId => _$this._versionId;
  set versionId(String? versionId) => _$this._versionId = versionId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  FontCatalogEntryDtoDesignLanguageEnum? _designLanguage;
  FontCatalogEntryDtoDesignLanguageEnum? get designLanguage =>
      _$this._designLanguage;
  set designLanguage(FontCatalogEntryDtoDesignLanguageEnum? designLanguage) =>
      _$this._designLanguage = designLanguage;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  bool? _selectable;
  bool? get selectable => _$this._selectable;
  set selectable(bool? selectable) => _$this._selectable = selectable;

  bool? _pasteAllowed;
  bool? get pasteAllowed => _$this._pasteAllowed;
  set pasteAllowed(bool? pasteAllowed) => _$this._pasteAllowed = pasteAllowed;

  bool? _renderAllowed;
  bool? get renderAllowed => _$this._renderAllowed;
  set renderAllowed(bool? renderAllowed) =>
      _$this._renderAllowed = renderAllowed;

  String? _assetBasePath;
  String? get assetBasePath => _$this._assetBasePath;
  set assetBasePath(String? assetBasePath) =>
      _$this._assetBasePath = assetBasePath;

  FontAssetDtoBuilder? _specimen;
  FontAssetDtoBuilder get specimen =>
      _$this._specimen ??= FontAssetDtoBuilder();
  set specimen(FontAssetDtoBuilder? specimen) => _$this._specimen = specimen;

  FontCatalogEntryDtoBuilder() {
    FontCatalogEntryDto._defaults(this);
  }

  FontCatalogEntryDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _familyId = $v.familyId;
      _versionId = $v.versionId;
      _name = $v.name;
      _designLanguage = $v.designLanguage;
      _sortOrder = $v.sortOrder;
      _selectable = $v.selectable;
      _pasteAllowed = $v.pasteAllowed;
      _renderAllowed = $v.renderAllowed;
      _assetBasePath = $v.assetBasePath;
      _specimen = $v.specimen.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontCatalogEntryDto other) {
    _$v = other as _$FontCatalogEntryDto;
  }

  @override
  void update(void Function(FontCatalogEntryDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontCatalogEntryDto build() => _build();

  _$FontCatalogEntryDto _build() {
    _$FontCatalogEntryDto _$result;
    try {
      _$result =
          _$v ??
          _$FontCatalogEntryDto._(
            familyId: BuiltValueNullFieldError.checkNotNull(
              familyId,
              r'FontCatalogEntryDto',
              'familyId',
            ),
            versionId: BuiltValueNullFieldError.checkNotNull(
              versionId,
              r'FontCatalogEntryDto',
              'versionId',
            ),
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'FontCatalogEntryDto',
              'name',
            ),
            designLanguage: BuiltValueNullFieldError.checkNotNull(
              designLanguage,
              r'FontCatalogEntryDto',
              'designLanguage',
            ),
            sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'FontCatalogEntryDto',
              'sortOrder',
            ),
            selectable: BuiltValueNullFieldError.checkNotNull(
              selectable,
              r'FontCatalogEntryDto',
              'selectable',
            ),
            pasteAllowed: BuiltValueNullFieldError.checkNotNull(
              pasteAllowed,
              r'FontCatalogEntryDto',
              'pasteAllowed',
            ),
            renderAllowed: BuiltValueNullFieldError.checkNotNull(
              renderAllowed,
              r'FontCatalogEntryDto',
              'renderAllowed',
            ),
            assetBasePath: BuiltValueNullFieldError.checkNotNull(
              assetBasePath,
              r'FontCatalogEntryDto',
              'assetBasePath',
            ),
            specimen: specimen.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'specimen';
        specimen.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontCatalogEntryDto',
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
