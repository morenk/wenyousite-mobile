// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_font_submission_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateFontSubmissionDtoLanguageEnum
_$createFontSubmissionDtoLanguageEnum_zh =
    const CreateFontSubmissionDtoLanguageEnum._('zh');
const CreateFontSubmissionDtoLanguageEnum
_$createFontSubmissionDtoLanguageEnum_ja =
    const CreateFontSubmissionDtoLanguageEnum._('ja');
const CreateFontSubmissionDtoLanguageEnum
_$createFontSubmissionDtoLanguageEnum_en =
    const CreateFontSubmissionDtoLanguageEnum._('en');
const CreateFontSubmissionDtoLanguageEnum
_$createFontSubmissionDtoLanguageEnum_other =
    const CreateFontSubmissionDtoLanguageEnum._('other');
const CreateFontSubmissionDtoLanguageEnum
_$createFontSubmissionDtoLanguageEnum_unknownDefaultOpenApi =
    const CreateFontSubmissionDtoLanguageEnum._('unknownDefaultOpenApi');

CreateFontSubmissionDtoLanguageEnum
_$createFontSubmissionDtoLanguageEnumValueOf(String name) {
  switch (name) {
    case 'zh':
      return _$createFontSubmissionDtoLanguageEnum_zh;
    case 'ja':
      return _$createFontSubmissionDtoLanguageEnum_ja;
    case 'en':
      return _$createFontSubmissionDtoLanguageEnum_en;
    case 'other':
      return _$createFontSubmissionDtoLanguageEnum_other;
    case 'unknownDefaultOpenApi':
      return _$createFontSubmissionDtoLanguageEnum_unknownDefaultOpenApi;
    default:
      return _$createFontSubmissionDtoLanguageEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CreateFontSubmissionDtoLanguageEnum>
_$createFontSubmissionDtoLanguageEnumValues =
    BuiltSet<CreateFontSubmissionDtoLanguageEnum>(
      const <CreateFontSubmissionDtoLanguageEnum>[
        _$createFontSubmissionDtoLanguageEnum_zh,
        _$createFontSubmissionDtoLanguageEnum_ja,
        _$createFontSubmissionDtoLanguageEnum_en,
        _$createFontSubmissionDtoLanguageEnum_other,
        _$createFontSubmissionDtoLanguageEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<CreateFontSubmissionDtoLanguageEnum>
_$createFontSubmissionDtoLanguageEnumSerializer =
    _$CreateFontSubmissionDtoLanguageEnumSerializer();

class _$CreateFontSubmissionDtoLanguageEnumSerializer
    implements PrimitiveSerializer<CreateFontSubmissionDtoLanguageEnum> {
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
    CreateFontSubmissionDtoLanguageEnum,
  ];
  @override
  final String wireName = 'CreateFontSubmissionDtoLanguageEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreateFontSubmissionDtoLanguageEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreateFontSubmissionDtoLanguageEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreateFontSubmissionDtoLanguageEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreateFontSubmissionDto extends CreateFontSubmissionDto {
  @override
  final String submissionId;
  @override
  final String name;
  @override
  final CreateFontSubmissionDtoLanguageEnum? language;
  @override
  final String? familyId;
  @override
  final int? expectedFamilyRevision;

  factory _$CreateFontSubmissionDto([
    void Function(CreateFontSubmissionDtoBuilder)? updates,
  ]) => (CreateFontSubmissionDtoBuilder()..update(updates))._build();

  _$CreateFontSubmissionDto._({
    required this.submissionId,
    required this.name,
    this.language,
    this.familyId,
    this.expectedFamilyRevision,
  }) : super._();
  @override
  CreateFontSubmissionDto rebuild(
    void Function(CreateFontSubmissionDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateFontSubmissionDtoBuilder toBuilder() =>
      CreateFontSubmissionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateFontSubmissionDto &&
        submissionId == other.submissionId &&
        name == other.name &&
        language == other.language &&
        familyId == other.familyId &&
        expectedFamilyRevision == other.expectedFamilyRevision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, submissionId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, familyId.hashCode);
    _$hash = $jc(_$hash, expectedFamilyRevision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateFontSubmissionDto')
          ..add('submissionId', submissionId)
          ..add('name', name)
          ..add('language', language)
          ..add('familyId', familyId)
          ..add('expectedFamilyRevision', expectedFamilyRevision))
        .toString();
  }
}

class CreateFontSubmissionDtoBuilder
    implements
        Builder<CreateFontSubmissionDto, CreateFontSubmissionDtoBuilder> {
  _$CreateFontSubmissionDto? _$v;

  String? _submissionId;
  String? get submissionId => _$this._submissionId;
  set submissionId(String? submissionId) => _$this._submissionId = submissionId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CreateFontSubmissionDtoLanguageEnum? _language;
  CreateFontSubmissionDtoLanguageEnum? get language => _$this._language;
  set language(CreateFontSubmissionDtoLanguageEnum? language) =>
      _$this._language = language;

  String? _familyId;
  String? get familyId => _$this._familyId;
  set familyId(String? familyId) => _$this._familyId = familyId;

  int? _expectedFamilyRevision;
  int? get expectedFamilyRevision => _$this._expectedFamilyRevision;
  set expectedFamilyRevision(int? expectedFamilyRevision) =>
      _$this._expectedFamilyRevision = expectedFamilyRevision;

  CreateFontSubmissionDtoBuilder() {
    CreateFontSubmissionDto._defaults(this);
  }

  CreateFontSubmissionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _submissionId = $v.submissionId;
      _name = $v.name;
      _language = $v.language;
      _familyId = $v.familyId;
      _expectedFamilyRevision = $v.expectedFamilyRevision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateFontSubmissionDto other) {
    _$v = other as _$CreateFontSubmissionDto;
  }

  @override
  void update(void Function(CreateFontSubmissionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateFontSubmissionDto build() => _build();

  _$CreateFontSubmissionDto _build() {
    final _$result =
        _$v ??
        _$CreateFontSubmissionDto._(
          submissionId: BuiltValueNullFieldError.checkNotNull(
            submissionId,
            r'CreateFontSubmissionDto',
            'submissionId',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'CreateFontSubmissionDto',
            'name',
          ),
          language: language,
          familyId: familyId,
          expectedFamilyRevision: expectedFamilyRevision,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
