// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_font_configuration_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateFontConfigurationDtoDesignLanguageEnum
_$updateFontConfigurationDtoDesignLanguageEnum_zh =
    const UpdateFontConfigurationDtoDesignLanguageEnum._('zh');
const UpdateFontConfigurationDtoDesignLanguageEnum
_$updateFontConfigurationDtoDesignLanguageEnum_ja =
    const UpdateFontConfigurationDtoDesignLanguageEnum._('ja');
const UpdateFontConfigurationDtoDesignLanguageEnum
_$updateFontConfigurationDtoDesignLanguageEnum_en =
    const UpdateFontConfigurationDtoDesignLanguageEnum._('en');
const UpdateFontConfigurationDtoDesignLanguageEnum
_$updateFontConfigurationDtoDesignLanguageEnum_other =
    const UpdateFontConfigurationDtoDesignLanguageEnum._('other');
const UpdateFontConfigurationDtoDesignLanguageEnum
_$updateFontConfigurationDtoDesignLanguageEnum_unknownDefaultOpenApi =
    const UpdateFontConfigurationDtoDesignLanguageEnum._(
      'unknownDefaultOpenApi',
    );

UpdateFontConfigurationDtoDesignLanguageEnum
_$updateFontConfigurationDtoDesignLanguageEnumValueOf(String name) {
  switch (name) {
    case 'zh':
      return _$updateFontConfigurationDtoDesignLanguageEnum_zh;
    case 'ja':
      return _$updateFontConfigurationDtoDesignLanguageEnum_ja;
    case 'en':
      return _$updateFontConfigurationDtoDesignLanguageEnum_en;
    case 'other':
      return _$updateFontConfigurationDtoDesignLanguageEnum_other;
    case 'unknownDefaultOpenApi':
      return _$updateFontConfigurationDtoDesignLanguageEnum_unknownDefaultOpenApi;
    default:
      return _$updateFontConfigurationDtoDesignLanguageEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpdateFontConfigurationDtoDesignLanguageEnum>
_$updateFontConfigurationDtoDesignLanguageEnumValues =
    BuiltSet<UpdateFontConfigurationDtoDesignLanguageEnum>(
      const <UpdateFontConfigurationDtoDesignLanguageEnum>[
        _$updateFontConfigurationDtoDesignLanguageEnum_zh,
        _$updateFontConfigurationDtoDesignLanguageEnum_ja,
        _$updateFontConfigurationDtoDesignLanguageEnum_en,
        _$updateFontConfigurationDtoDesignLanguageEnum_other,
        _$updateFontConfigurationDtoDesignLanguageEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UpdateFontConfigurationDtoDesignLanguageEnum>
_$updateFontConfigurationDtoDesignLanguageEnumSerializer =
    _$UpdateFontConfigurationDtoDesignLanguageEnumSerializer();

class _$UpdateFontConfigurationDtoDesignLanguageEnumSerializer
    implements
        PrimitiveSerializer<UpdateFontConfigurationDtoDesignLanguageEnum> {
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
    UpdateFontConfigurationDtoDesignLanguageEnum,
  ];
  @override
  final String wireName = 'UpdateFontConfigurationDtoDesignLanguageEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpdateFontConfigurationDtoDesignLanguageEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpdateFontConfigurationDtoDesignLanguageEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpdateFontConfigurationDtoDesignLanguageEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpdateFontConfigurationDto extends UpdateFontConfigurationDto {
  @override
  final String name;
  @override
  final UpdateFontConfigurationDtoDesignLanguageEnum designLanguage;
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
  final int expectedFamilyRevision;

  factory _$UpdateFontConfigurationDto([
    void Function(UpdateFontConfigurationDtoBuilder)? updates,
  ]) => (UpdateFontConfigurationDtoBuilder()..update(updates))._build();

  _$UpdateFontConfigurationDto._({
    required this.name,
    required this.designLanguage,
    required this.sortOrder,
    required this.author,
    required this.sourceUrl,
    required this.licenseName,
    required this.licenseText,
    required this.specimenText,
    required this.rights,
    required this.expectedFamilyRevision,
  }) : super._();
  @override
  UpdateFontConfigurationDto rebuild(
    void Function(UpdateFontConfigurationDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateFontConfigurationDtoBuilder toBuilder() =>
      UpdateFontConfigurationDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateFontConfigurationDto &&
        name == other.name &&
        designLanguage == other.designLanguage &&
        sortOrder == other.sortOrder &&
        author == other.author &&
        sourceUrl == other.sourceUrl &&
        licenseName == other.licenseName &&
        licenseText == other.licenseText &&
        specimenText == other.specimenText &&
        rights == other.rights &&
        expectedFamilyRevision == other.expectedFamilyRevision;
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
    _$hash = $jc(_$hash, expectedFamilyRevision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateFontConfigurationDto')
          ..add('name', name)
          ..add('designLanguage', designLanguage)
          ..add('sortOrder', sortOrder)
          ..add('author', author)
          ..add('sourceUrl', sourceUrl)
          ..add('licenseName', licenseName)
          ..add('licenseText', licenseText)
          ..add('specimenText', specimenText)
          ..add('rights', rights)
          ..add('expectedFamilyRevision', expectedFamilyRevision))
        .toString();
  }
}

class UpdateFontConfigurationDtoBuilder
    implements
        Builder<UpdateFontConfigurationDto, UpdateFontConfigurationDtoBuilder> {
  _$UpdateFontConfigurationDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  UpdateFontConfigurationDtoDesignLanguageEnum? _designLanguage;
  UpdateFontConfigurationDtoDesignLanguageEnum? get designLanguage =>
      _$this._designLanguage;
  set designLanguage(
    UpdateFontConfigurationDtoDesignLanguageEnum? designLanguage,
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

  int? _expectedFamilyRevision;
  int? get expectedFamilyRevision => _$this._expectedFamilyRevision;
  set expectedFamilyRevision(int? expectedFamilyRevision) =>
      _$this._expectedFamilyRevision = expectedFamilyRevision;

  UpdateFontConfigurationDtoBuilder() {
    UpdateFontConfigurationDto._defaults(this);
  }

  UpdateFontConfigurationDtoBuilder get _$this {
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
      _expectedFamilyRevision = $v.expectedFamilyRevision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateFontConfigurationDto other) {
    _$v = other as _$UpdateFontConfigurationDto;
  }

  @override
  void update(void Function(UpdateFontConfigurationDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateFontConfigurationDto build() => _build();

  _$UpdateFontConfigurationDto _build() {
    _$UpdateFontConfigurationDto _$result;
    try {
      _$result =
          _$v ??
          _$UpdateFontConfigurationDto._(
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'UpdateFontConfigurationDto',
              'name',
            ),
            designLanguage: BuiltValueNullFieldError.checkNotNull(
              designLanguage,
              r'UpdateFontConfigurationDto',
              'designLanguage',
            ),
            sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'UpdateFontConfigurationDto',
              'sortOrder',
            ),
            author: BuiltValueNullFieldError.checkNotNull(
              author,
              r'UpdateFontConfigurationDto',
              'author',
            ),
            sourceUrl: BuiltValueNullFieldError.checkNotNull(
              sourceUrl,
              r'UpdateFontConfigurationDto',
              'sourceUrl',
            ),
            licenseName: BuiltValueNullFieldError.checkNotNull(
              licenseName,
              r'UpdateFontConfigurationDto',
              'licenseName',
            ),
            licenseText: BuiltValueNullFieldError.checkNotNull(
              licenseText,
              r'UpdateFontConfigurationDto',
              'licenseText',
            ),
            specimenText: BuiltValueNullFieldError.checkNotNull(
              specimenText,
              r'UpdateFontConfigurationDto',
              'specimenText',
            ),
            rights: rights.build(),
            expectedFamilyRevision: BuiltValueNullFieldError.checkNotNull(
              expectedFamilyRevision,
              r'UpdateFontConfigurationDto',
              'expectedFamilyRevision',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rights';
        rights.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'UpdateFontConfigurationDto',
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
