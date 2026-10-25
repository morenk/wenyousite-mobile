// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_configuration_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontConfigurationDtoDesignLanguageEnum
_$fontConfigurationDtoDesignLanguageEnum_zh =
    const FontConfigurationDtoDesignLanguageEnum._('zh');
const FontConfigurationDtoDesignLanguageEnum
_$fontConfigurationDtoDesignLanguageEnum_ja =
    const FontConfigurationDtoDesignLanguageEnum._('ja');
const FontConfigurationDtoDesignLanguageEnum
_$fontConfigurationDtoDesignLanguageEnum_en =
    const FontConfigurationDtoDesignLanguageEnum._('en');
const FontConfigurationDtoDesignLanguageEnum
_$fontConfigurationDtoDesignLanguageEnum_other =
    const FontConfigurationDtoDesignLanguageEnum._('other');
const FontConfigurationDtoDesignLanguageEnum
_$fontConfigurationDtoDesignLanguageEnum_unknownDefaultOpenApi =
    const FontConfigurationDtoDesignLanguageEnum._('unknownDefaultOpenApi');

FontConfigurationDtoDesignLanguageEnum
_$fontConfigurationDtoDesignLanguageEnumValueOf(String name) {
  switch (name) {
    case 'zh':
      return _$fontConfigurationDtoDesignLanguageEnum_zh;
    case 'ja':
      return _$fontConfigurationDtoDesignLanguageEnum_ja;
    case 'en':
      return _$fontConfigurationDtoDesignLanguageEnum_en;
    case 'other':
      return _$fontConfigurationDtoDesignLanguageEnum_other;
    case 'unknownDefaultOpenApi':
      return _$fontConfigurationDtoDesignLanguageEnum_unknownDefaultOpenApi;
    default:
      return _$fontConfigurationDtoDesignLanguageEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontConfigurationDtoDesignLanguageEnum>
_$fontConfigurationDtoDesignLanguageEnumValues =
    BuiltSet<FontConfigurationDtoDesignLanguageEnum>(
      const <FontConfigurationDtoDesignLanguageEnum>[
        _$fontConfigurationDtoDesignLanguageEnum_zh,
        _$fontConfigurationDtoDesignLanguageEnum_ja,
        _$fontConfigurationDtoDesignLanguageEnum_en,
        _$fontConfigurationDtoDesignLanguageEnum_other,
        _$fontConfigurationDtoDesignLanguageEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<FontConfigurationDtoDesignLanguageEnum>
_$fontConfigurationDtoDesignLanguageEnumSerializer =
    _$FontConfigurationDtoDesignLanguageEnumSerializer();

class _$FontConfigurationDtoDesignLanguageEnumSerializer
    implements PrimitiveSerializer<FontConfigurationDtoDesignLanguageEnum> {
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
    FontConfigurationDtoDesignLanguageEnum,
  ];
  @override
  final String wireName = 'FontConfigurationDtoDesignLanguageEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontConfigurationDtoDesignLanguageEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontConfigurationDtoDesignLanguageEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontConfigurationDtoDesignLanguageEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontConfigurationDto extends FontConfigurationDto {
  @override
  final String name;
  @override
  final FontConfigurationDtoDesignLanguageEnum designLanguage;
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

  factory _$FontConfigurationDto([
    void Function(FontConfigurationDtoBuilder)? updates,
  ]) => (FontConfigurationDtoBuilder()..update(updates))._build();

  _$FontConfigurationDto._({
    required this.name,
    required this.designLanguage,
    required this.sortOrder,
    required this.author,
    required this.sourceUrl,
    required this.licenseName,
    required this.licenseText,
    required this.specimenText,
    required this.rights,
  }) : super._();
  @override
  FontConfigurationDto rebuild(
    void Function(FontConfigurationDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontConfigurationDtoBuilder toBuilder() =>
      FontConfigurationDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontConfigurationDto &&
        name == other.name &&
        designLanguage == other.designLanguage &&
        sortOrder == other.sortOrder &&
        author == other.author &&
        sourceUrl == other.sourceUrl &&
        licenseName == other.licenseName &&
        licenseText == other.licenseText &&
        specimenText == other.specimenText &&
        rights == other.rights;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontConfigurationDto')
          ..add('name', name)
          ..add('designLanguage', designLanguage)
          ..add('sortOrder', sortOrder)
          ..add('author', author)
          ..add('sourceUrl', sourceUrl)
          ..add('licenseName', licenseName)
          ..add('licenseText', licenseText)
          ..add('specimenText', specimenText)
          ..add('rights', rights))
        .toString();
  }
}

class FontConfigurationDtoBuilder
    implements Builder<FontConfigurationDto, FontConfigurationDtoBuilder> {
  _$FontConfigurationDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  FontConfigurationDtoDesignLanguageEnum? _designLanguage;
  FontConfigurationDtoDesignLanguageEnum? get designLanguage =>
      _$this._designLanguage;
  set designLanguage(FontConfigurationDtoDesignLanguageEnum? designLanguage) =>
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

  FontConfigurationDtoBuilder() {
    FontConfigurationDto._defaults(this);
  }

  FontConfigurationDtoBuilder get _$this {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontConfigurationDto other) {
    _$v = other as _$FontConfigurationDto;
  }

  @override
  void update(void Function(FontConfigurationDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontConfigurationDto build() => _build();

  _$FontConfigurationDto _build() {
    _$FontConfigurationDto _$result;
    try {
      _$result =
          _$v ??
          _$FontConfigurationDto._(
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'FontConfigurationDto',
              'name',
            ),
            designLanguage: BuiltValueNullFieldError.checkNotNull(
              designLanguage,
              r'FontConfigurationDto',
              'designLanguage',
            ),
            sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'FontConfigurationDto',
              'sortOrder',
            ),
            author: BuiltValueNullFieldError.checkNotNull(
              author,
              r'FontConfigurationDto',
              'author',
            ),
            sourceUrl: BuiltValueNullFieldError.checkNotNull(
              sourceUrl,
              r'FontConfigurationDto',
              'sourceUrl',
            ),
            licenseName: BuiltValueNullFieldError.checkNotNull(
              licenseName,
              r'FontConfigurationDto',
              'licenseName',
            ),
            licenseText: BuiltValueNullFieldError.checkNotNull(
              licenseText,
              r'FontConfigurationDto',
              'licenseText',
            ),
            specimenText: BuiltValueNullFieldError.checkNotNull(
              specimenText,
              r'FontConfigurationDto',
              'specimenText',
            ),
            rights: rights.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rights';
        rights.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontConfigurationDto',
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
