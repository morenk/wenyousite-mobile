// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_version_descriptor_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontVersionDescriptorDtoFontVersionEnum
_$fontVersionDescriptorDtoFontVersionEnum_n2 =
    const FontVersionDescriptorDtoFontVersionEnum._('n2');
const FontVersionDescriptorDtoFontVersionEnum
_$fontVersionDescriptorDtoFontVersionEnum_unknownDefaultOpenApi =
    const FontVersionDescriptorDtoFontVersionEnum._('unknownDefaultOpenApi');

FontVersionDescriptorDtoFontVersionEnum
_$fontVersionDescriptorDtoFontVersionEnumValueOf(String name) {
  switch (name) {
    case 'n2':
      return _$fontVersionDescriptorDtoFontVersionEnum_n2;
    case 'unknownDefaultOpenApi':
      return _$fontVersionDescriptorDtoFontVersionEnum_unknownDefaultOpenApi;
    default:
      return _$fontVersionDescriptorDtoFontVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontVersionDescriptorDtoFontVersionEnum>
_$fontVersionDescriptorDtoFontVersionEnumValues =
    BuiltSet<FontVersionDescriptorDtoFontVersionEnum>(
      const <FontVersionDescriptorDtoFontVersionEnum>[
        _$fontVersionDescriptorDtoFontVersionEnum_n2,
        _$fontVersionDescriptorDtoFontVersionEnum_unknownDefaultOpenApi,
      ],
    );

const FontVersionDescriptorDtoDesignLanguageEnum
_$fontVersionDescriptorDtoDesignLanguageEnum_zh =
    const FontVersionDescriptorDtoDesignLanguageEnum._('zh');
const FontVersionDescriptorDtoDesignLanguageEnum
_$fontVersionDescriptorDtoDesignLanguageEnum_ja =
    const FontVersionDescriptorDtoDesignLanguageEnum._('ja');
const FontVersionDescriptorDtoDesignLanguageEnum
_$fontVersionDescriptorDtoDesignLanguageEnum_en =
    const FontVersionDescriptorDtoDesignLanguageEnum._('en');
const FontVersionDescriptorDtoDesignLanguageEnum
_$fontVersionDescriptorDtoDesignLanguageEnum_other =
    const FontVersionDescriptorDtoDesignLanguageEnum._('other');
const FontVersionDescriptorDtoDesignLanguageEnum
_$fontVersionDescriptorDtoDesignLanguageEnum_unknownDefaultOpenApi =
    const FontVersionDescriptorDtoDesignLanguageEnum._('unknownDefaultOpenApi');

FontVersionDescriptorDtoDesignLanguageEnum
_$fontVersionDescriptorDtoDesignLanguageEnumValueOf(String name) {
  switch (name) {
    case 'zh':
      return _$fontVersionDescriptorDtoDesignLanguageEnum_zh;
    case 'ja':
      return _$fontVersionDescriptorDtoDesignLanguageEnum_ja;
    case 'en':
      return _$fontVersionDescriptorDtoDesignLanguageEnum_en;
    case 'other':
      return _$fontVersionDescriptorDtoDesignLanguageEnum_other;
    case 'unknownDefaultOpenApi':
      return _$fontVersionDescriptorDtoDesignLanguageEnum_unknownDefaultOpenApi;
    default:
      return _$fontVersionDescriptorDtoDesignLanguageEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontVersionDescriptorDtoDesignLanguageEnum>
_$fontVersionDescriptorDtoDesignLanguageEnumValues =
    BuiltSet<FontVersionDescriptorDtoDesignLanguageEnum>(
      const <FontVersionDescriptorDtoDesignLanguageEnum>[
        _$fontVersionDescriptorDtoDesignLanguageEnum_zh,
        _$fontVersionDescriptorDtoDesignLanguageEnum_ja,
        _$fontVersionDescriptorDtoDesignLanguageEnum_en,
        _$fontVersionDescriptorDtoDesignLanguageEnum_other,
        _$fontVersionDescriptorDtoDesignLanguageEnum_unknownDefaultOpenApi,
      ],
    );

const FontVersionDescriptorDtoStatusEnum
_$fontVersionDescriptorDtoStatusEnum_published =
    const FontVersionDescriptorDtoStatusEnum._('published');
const FontVersionDescriptorDtoStatusEnum
_$fontVersionDescriptorDtoStatusEnum_disabled =
    const FontVersionDescriptorDtoStatusEnum._('disabled');
const FontVersionDescriptorDtoStatusEnum
_$fontVersionDescriptorDtoStatusEnum_withdrawn =
    const FontVersionDescriptorDtoStatusEnum._('withdrawn');
const FontVersionDescriptorDtoStatusEnum
_$fontVersionDescriptorDtoStatusEnum_preview =
    const FontVersionDescriptorDtoStatusEnum._('preview');
const FontVersionDescriptorDtoStatusEnum
_$fontVersionDescriptorDtoStatusEnum_unknownDefaultOpenApi =
    const FontVersionDescriptorDtoStatusEnum._('unknownDefaultOpenApi');

FontVersionDescriptorDtoStatusEnum _$fontVersionDescriptorDtoStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'published':
      return _$fontVersionDescriptorDtoStatusEnum_published;
    case 'disabled':
      return _$fontVersionDescriptorDtoStatusEnum_disabled;
    case 'withdrawn':
      return _$fontVersionDescriptorDtoStatusEnum_withdrawn;
    case 'preview':
      return _$fontVersionDescriptorDtoStatusEnum_preview;
    case 'unknownDefaultOpenApi':
      return _$fontVersionDescriptorDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$fontVersionDescriptorDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontVersionDescriptorDtoStatusEnum>
_$fontVersionDescriptorDtoStatusEnumValues =
    BuiltSet<FontVersionDescriptorDtoStatusEnum>(
      const <FontVersionDescriptorDtoStatusEnum>[
        _$fontVersionDescriptorDtoStatusEnum_published,
        _$fontVersionDescriptorDtoStatusEnum_disabled,
        _$fontVersionDescriptorDtoStatusEnum_withdrawn,
        _$fontVersionDescriptorDtoStatusEnum_preview,
        _$fontVersionDescriptorDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<FontVersionDescriptorDtoFontVersionEnum>
_$fontVersionDescriptorDtoFontVersionEnumSerializer =
    _$FontVersionDescriptorDtoFontVersionEnumSerializer();
Serializer<FontVersionDescriptorDtoDesignLanguageEnum>
_$fontVersionDescriptorDtoDesignLanguageEnumSerializer =
    _$FontVersionDescriptorDtoDesignLanguageEnumSerializer();
Serializer<FontVersionDescriptorDtoStatusEnum>
_$fontVersionDescriptorDtoStatusEnumSerializer =
    _$FontVersionDescriptorDtoStatusEnumSerializer();

class _$FontVersionDescriptorDtoFontVersionEnumSerializer
    implements PrimitiveSerializer<FontVersionDescriptorDtoFontVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n2': '2',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '2': 'n2',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    FontVersionDescriptorDtoFontVersionEnum,
  ];
  @override
  final String wireName = 'FontVersionDescriptorDtoFontVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontVersionDescriptorDtoFontVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontVersionDescriptorDtoFontVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontVersionDescriptorDtoFontVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontVersionDescriptorDtoDesignLanguageEnumSerializer
    implements PrimitiveSerializer<FontVersionDescriptorDtoDesignLanguageEnum> {
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
    FontVersionDescriptorDtoDesignLanguageEnum,
  ];
  @override
  final String wireName = 'FontVersionDescriptorDtoDesignLanguageEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontVersionDescriptorDtoDesignLanguageEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontVersionDescriptorDtoDesignLanguageEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontVersionDescriptorDtoDesignLanguageEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontVersionDescriptorDtoStatusEnumSerializer
    implements PrimitiveSerializer<FontVersionDescriptorDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'published': 'published',
    'disabled': 'disabled',
    'withdrawn': 'withdrawn',
    'preview': 'preview',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'published': 'published',
    'disabled': 'disabled',
    'withdrawn': 'withdrawn',
    'preview': 'preview',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[FontVersionDescriptorDtoStatusEnum];
  @override
  final String wireName = 'FontVersionDescriptorDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontVersionDescriptorDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontVersionDescriptorDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontVersionDescriptorDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontVersionDescriptorDto extends FontVersionDescriptorDto {
  @override
  final FontVersionDescriptorDtoFontVersionEnum fontVersion;
  @override
  final String versionId;
  @override
  final String familyId;
  @override
  final int versionNumber;
  @override
  final String name;
  @override
  final FontVersionDescriptorDtoDesignLanguageEnum designLanguage;
  @override
  final int revision;
  @override
  final FontVersionDescriptorDtoStatusEnum status;
  @override
  final bool selectable;
  @override
  final bool pasteAllowed;
  @override
  final bool renderAllowed;
  @override
  final String? assetBasePath;
  @override
  final FontAssetDto? manifest;
  @override
  final FontAssetDto? specimen;

  factory _$FontVersionDescriptorDto([
    void Function(FontVersionDescriptorDtoBuilder)? updates,
  ]) => (FontVersionDescriptorDtoBuilder()..update(updates))._build();

  _$FontVersionDescriptorDto._({
    required this.fontVersion,
    required this.versionId,
    required this.familyId,
    required this.versionNumber,
    required this.name,
    required this.designLanguage,
    required this.revision,
    required this.status,
    required this.selectable,
    required this.pasteAllowed,
    required this.renderAllowed,
    this.assetBasePath,
    this.manifest,
    this.specimen,
  }) : super._();
  @override
  FontVersionDescriptorDto rebuild(
    void Function(FontVersionDescriptorDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontVersionDescriptorDtoBuilder toBuilder() =>
      FontVersionDescriptorDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontVersionDescriptorDto &&
        fontVersion == other.fontVersion &&
        versionId == other.versionId &&
        familyId == other.familyId &&
        versionNumber == other.versionNumber &&
        name == other.name &&
        designLanguage == other.designLanguage &&
        revision == other.revision &&
        status == other.status &&
        selectable == other.selectable &&
        pasteAllowed == other.pasteAllowed &&
        renderAllowed == other.renderAllowed &&
        assetBasePath == other.assetBasePath &&
        manifest == other.manifest &&
        specimen == other.specimen;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fontVersion.hashCode);
    _$hash = $jc(_$hash, versionId.hashCode);
    _$hash = $jc(_$hash, familyId.hashCode);
    _$hash = $jc(_$hash, versionNumber.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, designLanguage.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, selectable.hashCode);
    _$hash = $jc(_$hash, pasteAllowed.hashCode);
    _$hash = $jc(_$hash, renderAllowed.hashCode);
    _$hash = $jc(_$hash, assetBasePath.hashCode);
    _$hash = $jc(_$hash, manifest.hashCode);
    _$hash = $jc(_$hash, specimen.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontVersionDescriptorDto')
          ..add('fontVersion', fontVersion)
          ..add('versionId', versionId)
          ..add('familyId', familyId)
          ..add('versionNumber', versionNumber)
          ..add('name', name)
          ..add('designLanguage', designLanguage)
          ..add('revision', revision)
          ..add('status', status)
          ..add('selectable', selectable)
          ..add('pasteAllowed', pasteAllowed)
          ..add('renderAllowed', renderAllowed)
          ..add('assetBasePath', assetBasePath)
          ..add('manifest', manifest)
          ..add('specimen', specimen))
        .toString();
  }
}

class FontVersionDescriptorDtoBuilder
    implements
        Builder<FontVersionDescriptorDto, FontVersionDescriptorDtoBuilder> {
  _$FontVersionDescriptorDto? _$v;

  FontVersionDescriptorDtoFontVersionEnum? _fontVersion;
  FontVersionDescriptorDtoFontVersionEnum? get fontVersion =>
      _$this._fontVersion;
  set fontVersion(FontVersionDescriptorDtoFontVersionEnum? fontVersion) =>
      _$this._fontVersion = fontVersion;

  String? _versionId;
  String? get versionId => _$this._versionId;
  set versionId(String? versionId) => _$this._versionId = versionId;

  String? _familyId;
  String? get familyId => _$this._familyId;
  set familyId(String? familyId) => _$this._familyId = familyId;

  int? _versionNumber;
  int? get versionNumber => _$this._versionNumber;
  set versionNumber(int? versionNumber) =>
      _$this._versionNumber = versionNumber;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  FontVersionDescriptorDtoDesignLanguageEnum? _designLanguage;
  FontVersionDescriptorDtoDesignLanguageEnum? get designLanguage =>
      _$this._designLanguage;
  set designLanguage(
    FontVersionDescriptorDtoDesignLanguageEnum? designLanguage,
  ) => _$this._designLanguage = designLanguage;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  FontVersionDescriptorDtoStatusEnum? _status;
  FontVersionDescriptorDtoStatusEnum? get status => _$this._status;
  set status(FontVersionDescriptorDtoStatusEnum? status) =>
      _$this._status = status;

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

  FontAssetDtoBuilder? _manifest;
  FontAssetDtoBuilder get manifest =>
      _$this._manifest ??= FontAssetDtoBuilder();
  set manifest(FontAssetDtoBuilder? manifest) => _$this._manifest = manifest;

  FontAssetDtoBuilder? _specimen;
  FontAssetDtoBuilder get specimen =>
      _$this._specimen ??= FontAssetDtoBuilder();
  set specimen(FontAssetDtoBuilder? specimen) => _$this._specimen = specimen;

  FontVersionDescriptorDtoBuilder() {
    FontVersionDescriptorDto._defaults(this);
  }

  FontVersionDescriptorDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fontVersion = $v.fontVersion;
      _versionId = $v.versionId;
      _familyId = $v.familyId;
      _versionNumber = $v.versionNumber;
      _name = $v.name;
      _designLanguage = $v.designLanguage;
      _revision = $v.revision;
      _status = $v.status;
      _selectable = $v.selectable;
      _pasteAllowed = $v.pasteAllowed;
      _renderAllowed = $v.renderAllowed;
      _assetBasePath = $v.assetBasePath;
      _manifest = $v.manifest?.toBuilder();
      _specimen = $v.specimen?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontVersionDescriptorDto other) {
    _$v = other as _$FontVersionDescriptorDto;
  }

  @override
  void update(void Function(FontVersionDescriptorDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontVersionDescriptorDto build() => _build();

  _$FontVersionDescriptorDto _build() {
    _$FontVersionDescriptorDto _$result;
    try {
      _$result =
          _$v ??
          _$FontVersionDescriptorDto._(
            fontVersion: BuiltValueNullFieldError.checkNotNull(
              fontVersion,
              r'FontVersionDescriptorDto',
              'fontVersion',
            ),
            versionId: BuiltValueNullFieldError.checkNotNull(
              versionId,
              r'FontVersionDescriptorDto',
              'versionId',
            ),
            familyId: BuiltValueNullFieldError.checkNotNull(
              familyId,
              r'FontVersionDescriptorDto',
              'familyId',
            ),
            versionNumber: BuiltValueNullFieldError.checkNotNull(
              versionNumber,
              r'FontVersionDescriptorDto',
              'versionNumber',
            ),
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'FontVersionDescriptorDto',
              'name',
            ),
            designLanguage: BuiltValueNullFieldError.checkNotNull(
              designLanguage,
              r'FontVersionDescriptorDto',
              'designLanguage',
            ),
            revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'FontVersionDescriptorDto',
              'revision',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'FontVersionDescriptorDto',
              'status',
            ),
            selectable: BuiltValueNullFieldError.checkNotNull(
              selectable,
              r'FontVersionDescriptorDto',
              'selectable',
            ),
            pasteAllowed: BuiltValueNullFieldError.checkNotNull(
              pasteAllowed,
              r'FontVersionDescriptorDto',
              'pasteAllowed',
            ),
            renderAllowed: BuiltValueNullFieldError.checkNotNull(
              renderAllowed,
              r'FontVersionDescriptorDto',
              'renderAllowed',
            ),
            assetBasePath: assetBasePath,
            manifest: _manifest?.build(),
            specimen: _specimen?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'manifest';
        _manifest?.build();
        _$failedField = 'specimen';
        _specimen?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontVersionDescriptorDto',
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
