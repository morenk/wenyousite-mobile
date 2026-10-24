// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_family_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontFamilyDtoDesignLanguageEnum _$fontFamilyDtoDesignLanguageEnum_zh =
    const FontFamilyDtoDesignLanguageEnum._('zh');
const FontFamilyDtoDesignLanguageEnum _$fontFamilyDtoDesignLanguageEnum_ja =
    const FontFamilyDtoDesignLanguageEnum._('ja');
const FontFamilyDtoDesignLanguageEnum _$fontFamilyDtoDesignLanguageEnum_en =
    const FontFamilyDtoDesignLanguageEnum._('en');
const FontFamilyDtoDesignLanguageEnum _$fontFamilyDtoDesignLanguageEnum_other =
    const FontFamilyDtoDesignLanguageEnum._('other');
const FontFamilyDtoDesignLanguageEnum
_$fontFamilyDtoDesignLanguageEnum_unknownDefaultOpenApi =
    const FontFamilyDtoDesignLanguageEnum._('unknownDefaultOpenApi');

FontFamilyDtoDesignLanguageEnum _$fontFamilyDtoDesignLanguageEnumValueOf(
  String name,
) {
  switch (name) {
    case 'zh':
      return _$fontFamilyDtoDesignLanguageEnum_zh;
    case 'ja':
      return _$fontFamilyDtoDesignLanguageEnum_ja;
    case 'en':
      return _$fontFamilyDtoDesignLanguageEnum_en;
    case 'other':
      return _$fontFamilyDtoDesignLanguageEnum_other;
    case 'unknownDefaultOpenApi':
      return _$fontFamilyDtoDesignLanguageEnum_unknownDefaultOpenApi;
    default:
      return _$fontFamilyDtoDesignLanguageEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontFamilyDtoDesignLanguageEnum>
_$fontFamilyDtoDesignLanguageEnumValues =
    BuiltSet<FontFamilyDtoDesignLanguageEnum>(
      const <FontFamilyDtoDesignLanguageEnum>[
        _$fontFamilyDtoDesignLanguageEnum_zh,
        _$fontFamilyDtoDesignLanguageEnum_ja,
        _$fontFamilyDtoDesignLanguageEnum_en,
        _$fontFamilyDtoDesignLanguageEnum_other,
        _$fontFamilyDtoDesignLanguageEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<FontFamilyDtoDesignLanguageEnum>
_$fontFamilyDtoDesignLanguageEnumSerializer =
    _$FontFamilyDtoDesignLanguageEnumSerializer();

class _$FontFamilyDtoDesignLanguageEnumSerializer
    implements PrimitiveSerializer<FontFamilyDtoDesignLanguageEnum> {
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
  final Iterable<Type> types = const <Type>[FontFamilyDtoDesignLanguageEnum];
  @override
  final String wireName = 'FontFamilyDtoDesignLanguageEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontFamilyDtoDesignLanguageEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontFamilyDtoDesignLanguageEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontFamilyDtoDesignLanguageEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontFamilyDto extends FontFamilyDto {
  @override
  final String name;
  @override
  final FontFamilyDtoDesignLanguageEnum designLanguage;
  @override
  final int sortOrder;
  @override
  final String author;
  @override
  final String sourceUrl;
  @override
  final String licenseName;
  @override
  final String licenseText;
  @override
  final String specimenText;
  @override
  final FontRightsDto rights;
  @override
  final String familyId;
  @override
  final int revision;
  @override
  final bool enabled;
  @override
  final String? currentVersionId;
  @override
  final int catalogRevision;

  factory _$FontFamilyDto([void Function(FontFamilyDtoBuilder)? updates]) =>
      (FontFamilyDtoBuilder()..update(updates))._build();

  _$FontFamilyDto._({
    required this.name,
    required this.designLanguage,
    required this.sortOrder,
    required this.author,
    required this.sourceUrl,
    required this.licenseName,
    required this.licenseText,
    required this.specimenText,
    required this.rights,
    required this.familyId,
    required this.revision,
    required this.enabled,
    this.currentVersionId,
    required this.catalogRevision,
  }) : super._();
  @override
  FontFamilyDto rebuild(void Function(FontFamilyDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontFamilyDtoBuilder toBuilder() => FontFamilyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontFamilyDto &&
        name == other.name &&
        designLanguage == other.designLanguage &&
        sortOrder == other.sortOrder &&
        author == other.author &&
        sourceUrl == other.sourceUrl &&
        licenseName == other.licenseName &&
        licenseText == other.licenseText &&
        specimenText == other.specimenText &&
        rights == other.rights &&
        familyId == other.familyId &&
        revision == other.revision &&
        enabled == other.enabled &&
        currentVersionId == other.currentVersionId &&
        catalogRevision == other.catalogRevision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, designLanguage.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, sourceUrl.hashCode);
    _$hash = $jc(_$hash, licenseName.hashCode);
    _$hash = $jc(_$hash, licenseText.hashCode);
    _$hash = $jc(_$hash, specimenText.hashCode);
    _$hash = $jc(_$hash, rights.hashCode);
    _$hash = $jc(_$hash, familyId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, currentVersionId.hashCode);
    _$hash = $jc(_$hash, catalogRevision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontFamilyDto')
          ..add('name', name)
          ..add('designLanguage', designLanguage)
          ..add('sortOrder', sortOrder)
          ..add('author', author)
          ..add('sourceUrl', sourceUrl)
          ..add('licenseName', licenseName)
          ..add('licenseText', licenseText)
          ..add('specimenText', specimenText)
          ..add('rights', rights)
          ..add('familyId', familyId)
          ..add('revision', revision)
          ..add('enabled', enabled)
          ..add('currentVersionId', currentVersionId)
          ..add('catalogRevision', catalogRevision))
        .toString();
  }
}

class FontFamilyDtoBuilder
    implements Builder<FontFamilyDto, FontFamilyDtoBuilder> {
  _$FontFamilyDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  FontFamilyDtoDesignLanguageEnum? _designLanguage;
  FontFamilyDtoDesignLanguageEnum? get designLanguage => _$this._designLanguage;
  set designLanguage(FontFamilyDtoDesignLanguageEnum? designLanguage) =>
      _$this._designLanguage = designLanguage;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  String? _author;
  String? get author => _$this._author;
  set author(String? author) => _$this._author = author;

  String? _sourceUrl;
  String? get sourceUrl => _$this._sourceUrl;
  set sourceUrl(String? sourceUrl) => _$this._sourceUrl = sourceUrl;

  String? _licenseName;
  String? get licenseName => _$this._licenseName;
  set licenseName(String? licenseName) => _$this._licenseName = licenseName;

  String? _licenseText;
  String? get licenseText => _$this._licenseText;
  set licenseText(String? licenseText) => _$this._licenseText = licenseText;

  String? _specimenText;
  String? get specimenText => _$this._specimenText;
  set specimenText(String? specimenText) => _$this._specimenText = specimenText;

  FontRightsDtoBuilder? _rights;
  FontRightsDtoBuilder get rights => _$this._rights ??= FontRightsDtoBuilder();
  set rights(FontRightsDtoBuilder? rights) => _$this._rights = rights;

  String? _familyId;
  String? get familyId => _$this._familyId;
  set familyId(String? familyId) => _$this._familyId = familyId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  String? _currentVersionId;
  String? get currentVersionId => _$this._currentVersionId;
  set currentVersionId(String? currentVersionId) =>
      _$this._currentVersionId = currentVersionId;

  int? _catalogRevision;
  int? get catalogRevision => _$this._catalogRevision;
  set catalogRevision(int? catalogRevision) =>
      _$this._catalogRevision = catalogRevision;

  FontFamilyDtoBuilder() {
    FontFamilyDto._defaults(this);
  }

  FontFamilyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _designLanguage = $v.designLanguage;
      _sortOrder = $v.sortOrder;
      _author = $v.author;
      _sourceUrl = $v.sourceUrl;
      _licenseName = $v.licenseName;
      _licenseText = $v.licenseText;
      _specimenText = $v.specimenText;
      _rights = $v.rights.toBuilder();
      _familyId = $v.familyId;
      _revision = $v.revision;
      _enabled = $v.enabled;
      _currentVersionId = $v.currentVersionId;
      _catalogRevision = $v.catalogRevision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontFamilyDto other) {
    _$v = other as _$FontFamilyDto;
  }

  @override
  void update(void Function(FontFamilyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontFamilyDto build() => _build();

  _$FontFamilyDto _build() {
    _$FontFamilyDto _$result;
    try {
      _$result =
          _$v ??
          _$FontFamilyDto._(
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'FontFamilyDto',
              'name',
            ),
            designLanguage: BuiltValueNullFieldError.checkNotNull(
              designLanguage,
              r'FontFamilyDto',
              'designLanguage',
            ),
            sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'FontFamilyDto',
              'sortOrder',
            ),
            author: BuiltValueNullFieldError.checkNotNull(
              author,
              r'FontFamilyDto',
              'author',
            ),
            sourceUrl: BuiltValueNullFieldError.checkNotNull(
              sourceUrl,
              r'FontFamilyDto',
              'sourceUrl',
            ),
            licenseName: BuiltValueNullFieldError.checkNotNull(
              licenseName,
              r'FontFamilyDto',
              'licenseName',
            ),
            licenseText: BuiltValueNullFieldError.checkNotNull(
              licenseText,
              r'FontFamilyDto',
              'licenseText',
            ),
            specimenText: BuiltValueNullFieldError.checkNotNull(
              specimenText,
              r'FontFamilyDto',
              'specimenText',
            ),
            rights: rights.build(),
            familyId: BuiltValueNullFieldError.checkNotNull(
              familyId,
              r'FontFamilyDto',
              'familyId',
            ),
            revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'FontFamilyDto',
              'revision',
            ),
            enabled: BuiltValueNullFieldError.checkNotNull(
              enabled,
              r'FontFamilyDto',
              'enabled',
            ),
            currentVersionId: currentVersionId,
            catalogRevision: BuiltValueNullFieldError.checkNotNull(
              catalogRevision,
              r'FontFamilyDto',
              'catalogRevision',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rights';
        rights.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontFamilyDto',
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
