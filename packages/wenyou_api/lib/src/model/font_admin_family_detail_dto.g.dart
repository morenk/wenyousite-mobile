// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_admin_family_detail_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontAdminFamilyDetailDtoDesignLanguageEnum
_$fontAdminFamilyDetailDtoDesignLanguageEnum_zh =
    const FontAdminFamilyDetailDtoDesignLanguageEnum._('zh');
const FontAdminFamilyDetailDtoDesignLanguageEnum
_$fontAdminFamilyDetailDtoDesignLanguageEnum_ja =
    const FontAdminFamilyDetailDtoDesignLanguageEnum._('ja');
const FontAdminFamilyDetailDtoDesignLanguageEnum
_$fontAdminFamilyDetailDtoDesignLanguageEnum_en =
    const FontAdminFamilyDetailDtoDesignLanguageEnum._('en');
const FontAdminFamilyDetailDtoDesignLanguageEnum
_$fontAdminFamilyDetailDtoDesignLanguageEnum_other =
    const FontAdminFamilyDetailDtoDesignLanguageEnum._('other');
const FontAdminFamilyDetailDtoDesignLanguageEnum
_$fontAdminFamilyDetailDtoDesignLanguageEnum_unknownDefaultOpenApi =
    const FontAdminFamilyDetailDtoDesignLanguageEnum._('unknownDefaultOpenApi');

FontAdminFamilyDetailDtoDesignLanguageEnum
_$fontAdminFamilyDetailDtoDesignLanguageEnumValueOf(String name) {
  switch (name) {
    case 'zh':
      return _$fontAdminFamilyDetailDtoDesignLanguageEnum_zh;
    case 'ja':
      return _$fontAdminFamilyDetailDtoDesignLanguageEnum_ja;
    case 'en':
      return _$fontAdminFamilyDetailDtoDesignLanguageEnum_en;
    case 'other':
      return _$fontAdminFamilyDetailDtoDesignLanguageEnum_other;
    case 'unknownDefaultOpenApi':
      return _$fontAdminFamilyDetailDtoDesignLanguageEnum_unknownDefaultOpenApi;
    default:
      return _$fontAdminFamilyDetailDtoDesignLanguageEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontAdminFamilyDetailDtoDesignLanguageEnum>
_$fontAdminFamilyDetailDtoDesignLanguageEnumValues =
    BuiltSet<FontAdminFamilyDetailDtoDesignLanguageEnum>(
      const <FontAdminFamilyDetailDtoDesignLanguageEnum>[
        _$fontAdminFamilyDetailDtoDesignLanguageEnum_zh,
        _$fontAdminFamilyDetailDtoDesignLanguageEnum_ja,
        _$fontAdminFamilyDetailDtoDesignLanguageEnum_en,
        _$fontAdminFamilyDetailDtoDesignLanguageEnum_other,
        _$fontAdminFamilyDetailDtoDesignLanguageEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<FontAdminFamilyDetailDtoDesignLanguageEnum>
_$fontAdminFamilyDetailDtoDesignLanguageEnumSerializer =
    _$FontAdminFamilyDetailDtoDesignLanguageEnumSerializer();

class _$FontAdminFamilyDetailDtoDesignLanguageEnumSerializer
    implements PrimitiveSerializer<FontAdminFamilyDetailDtoDesignLanguageEnum> {
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
    FontAdminFamilyDetailDtoDesignLanguageEnum,
  ];
  @override
  final String wireName = 'FontAdminFamilyDetailDtoDesignLanguageEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontAdminFamilyDetailDtoDesignLanguageEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontAdminFamilyDetailDtoDesignLanguageEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontAdminFamilyDetailDtoDesignLanguageEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontAdminFamilyDetailDto extends FontAdminFamilyDetailDto {
  @override
  final String name;
  @override
  final FontAdminFamilyDetailDtoDesignLanguageEnum designLanguage;
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
  @override
  final BuiltList<FontJobDto> jobs;
  @override
  final BuiltList<String> versionIds;

  factory _$FontAdminFamilyDetailDto([
    void Function(FontAdminFamilyDetailDtoBuilder)? updates,
  ]) => (FontAdminFamilyDetailDtoBuilder()..update(updates))._build();

  _$FontAdminFamilyDetailDto._({
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
    required this.jobs,
    required this.versionIds,
  }) : super._();
  @override
  FontAdminFamilyDetailDto rebuild(
    void Function(FontAdminFamilyDetailDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontAdminFamilyDetailDtoBuilder toBuilder() =>
      FontAdminFamilyDetailDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontAdminFamilyDetailDto &&
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
        catalogRevision == other.catalogRevision &&
        jobs == other.jobs &&
        versionIds == other.versionIds;
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
    _$hash = $jc(_$hash, jobs.hashCode);
    _$hash = $jc(_$hash, versionIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontAdminFamilyDetailDto')
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
          ..add('catalogRevision', catalogRevision)
          ..add('jobs', jobs)
          ..add('versionIds', versionIds))
        .toString();
  }
}

class FontAdminFamilyDetailDtoBuilder
    implements
        Builder<FontAdminFamilyDetailDto, FontAdminFamilyDetailDtoBuilder> {
  _$FontAdminFamilyDetailDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  FontAdminFamilyDetailDtoDesignLanguageEnum? _designLanguage;
  FontAdminFamilyDetailDtoDesignLanguageEnum? get designLanguage =>
      _$this._designLanguage;
  set designLanguage(
    FontAdminFamilyDetailDtoDesignLanguageEnum? designLanguage,
  ) => _$this._designLanguage = designLanguage;

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

  ListBuilder<FontJobDto>? _jobs;
  ListBuilder<FontJobDto> get jobs =>
      _$this._jobs ??= ListBuilder<FontJobDto>();
  set jobs(ListBuilder<FontJobDto>? jobs) => _$this._jobs = jobs;

  ListBuilder<String>? _versionIds;
  ListBuilder<String> get versionIds =>
      _$this._versionIds ??= ListBuilder<String>();
  set versionIds(ListBuilder<String>? versionIds) =>
      _$this._versionIds = versionIds;

  FontAdminFamilyDetailDtoBuilder() {
    FontAdminFamilyDetailDto._defaults(this);
  }

  FontAdminFamilyDetailDtoBuilder get _$this {
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
      _jobs = $v.jobs.toBuilder();
      _versionIds = $v.versionIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontAdminFamilyDetailDto other) {
    _$v = other as _$FontAdminFamilyDetailDto;
  }

  @override
  void update(void Function(FontAdminFamilyDetailDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontAdminFamilyDetailDto build() => _build();

  _$FontAdminFamilyDetailDto _build() {
    _$FontAdminFamilyDetailDto _$result;
    try {
      _$result =
          _$v ??
          _$FontAdminFamilyDetailDto._(
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'FontAdminFamilyDetailDto',
              'name',
            ),
            designLanguage: BuiltValueNullFieldError.checkNotNull(
              designLanguage,
              r'FontAdminFamilyDetailDto',
              'designLanguage',
            ),
            sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'FontAdminFamilyDetailDto',
              'sortOrder',
            ),
            author: BuiltValueNullFieldError.checkNotNull(
              author,
              r'FontAdminFamilyDetailDto',
              'author',
            ),
            sourceUrl: BuiltValueNullFieldError.checkNotNull(
              sourceUrl,
              r'FontAdminFamilyDetailDto',
              'sourceUrl',
            ),
            licenseName: BuiltValueNullFieldError.checkNotNull(
              licenseName,
              r'FontAdminFamilyDetailDto',
              'licenseName',
            ),
            licenseText: BuiltValueNullFieldError.checkNotNull(
              licenseText,
              r'FontAdminFamilyDetailDto',
              'licenseText',
            ),
            specimenText: BuiltValueNullFieldError.checkNotNull(
              specimenText,
              r'FontAdminFamilyDetailDto',
              'specimenText',
            ),
            rights: rights.build(),
            familyId: BuiltValueNullFieldError.checkNotNull(
              familyId,
              r'FontAdminFamilyDetailDto',
              'familyId',
            ),
            revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'FontAdminFamilyDetailDto',
              'revision',
            ),
            enabled: BuiltValueNullFieldError.checkNotNull(
              enabled,
              r'FontAdminFamilyDetailDto',
              'enabled',
            ),
            currentVersionId: currentVersionId,
            catalogRevision: BuiltValueNullFieldError.checkNotNull(
              catalogRevision,
              r'FontAdminFamilyDetailDto',
              'catalogRevision',
            ),
            jobs: jobs.build(),
            versionIds: versionIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rights';
        rights.build();

        _$failedField = 'jobs';
        jobs.build();
        _$failedField = 'versionIds';
        versionIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontAdminFamilyDetailDto',
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
