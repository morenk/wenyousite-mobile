// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_submission_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontSubmissionDtoLanguageEnum _$fontSubmissionDtoLanguageEnum_zh =
    const FontSubmissionDtoLanguageEnum._('zh');
const FontSubmissionDtoLanguageEnum _$fontSubmissionDtoLanguageEnum_ja =
    const FontSubmissionDtoLanguageEnum._('ja');
const FontSubmissionDtoLanguageEnum _$fontSubmissionDtoLanguageEnum_en =
    const FontSubmissionDtoLanguageEnum._('en');
const FontSubmissionDtoLanguageEnum _$fontSubmissionDtoLanguageEnum_other =
    const FontSubmissionDtoLanguageEnum._('other');
const FontSubmissionDtoLanguageEnum
_$fontSubmissionDtoLanguageEnum_unknownDefaultOpenApi =
    const FontSubmissionDtoLanguageEnum._('unknownDefaultOpenApi');

FontSubmissionDtoLanguageEnum _$fontSubmissionDtoLanguageEnumValueOf(
  String name,
) {
  switch (name) {
    case 'zh':
      return _$fontSubmissionDtoLanguageEnum_zh;
    case 'ja':
      return _$fontSubmissionDtoLanguageEnum_ja;
    case 'en':
      return _$fontSubmissionDtoLanguageEnum_en;
    case 'other':
      return _$fontSubmissionDtoLanguageEnum_other;
    case 'unknownDefaultOpenApi':
      return _$fontSubmissionDtoLanguageEnum_unknownDefaultOpenApi;
    default:
      return _$fontSubmissionDtoLanguageEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontSubmissionDtoLanguageEnum>
_$fontSubmissionDtoLanguageEnumValues = BuiltSet<FontSubmissionDtoLanguageEnum>(
  const <FontSubmissionDtoLanguageEnum>[
    _$fontSubmissionDtoLanguageEnum_zh,
    _$fontSubmissionDtoLanguageEnum_ja,
    _$fontSubmissionDtoLanguageEnum_en,
    _$fontSubmissionDtoLanguageEnum_other,
    _$fontSubmissionDtoLanguageEnum_unknownDefaultOpenApi,
  ],
);

const FontSubmissionDtoAuthorizationRuleVersionEnum
_$fontSubmissionDtoAuthorizationRuleVersionEnum_adminFontUploadV1 =
    const FontSubmissionDtoAuthorizationRuleVersionEnum._('adminFontUploadV1');
const FontSubmissionDtoAuthorizationRuleVersionEnum
_$fontSubmissionDtoAuthorizationRuleVersionEnum_unknownDefaultOpenApi =
    const FontSubmissionDtoAuthorizationRuleVersionEnum._(
      'unknownDefaultOpenApi',
    );

FontSubmissionDtoAuthorizationRuleVersionEnum
_$fontSubmissionDtoAuthorizationRuleVersionEnumValueOf(String name) {
  switch (name) {
    case 'adminFontUploadV1':
      return _$fontSubmissionDtoAuthorizationRuleVersionEnum_adminFontUploadV1;
    case 'unknownDefaultOpenApi':
      return _$fontSubmissionDtoAuthorizationRuleVersionEnum_unknownDefaultOpenApi;
    default:
      return _$fontSubmissionDtoAuthorizationRuleVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontSubmissionDtoAuthorizationRuleVersionEnum>
_$fontSubmissionDtoAuthorizationRuleVersionEnumValues =
    BuiltSet<FontSubmissionDtoAuthorizationRuleVersionEnum>(
      const <FontSubmissionDtoAuthorizationRuleVersionEnum>[
        _$fontSubmissionDtoAuthorizationRuleVersionEnum_adminFontUploadV1,
        _$fontSubmissionDtoAuthorizationRuleVersionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<FontSubmissionDtoLanguageEnum>
_$fontSubmissionDtoLanguageEnumSerializer =
    _$FontSubmissionDtoLanguageEnumSerializer();
Serializer<FontSubmissionDtoAuthorizationRuleVersionEnum>
_$fontSubmissionDtoAuthorizationRuleVersionEnumSerializer =
    _$FontSubmissionDtoAuthorizationRuleVersionEnumSerializer();

class _$FontSubmissionDtoLanguageEnumSerializer
    implements PrimitiveSerializer<FontSubmissionDtoLanguageEnum> {
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
  final Iterable<Type> types = const <Type>[FontSubmissionDtoLanguageEnum];
  @override
  final String wireName = 'FontSubmissionDtoLanguageEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontSubmissionDtoLanguageEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontSubmissionDtoLanguageEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontSubmissionDtoLanguageEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontSubmissionDtoAuthorizationRuleVersionEnumSerializer
    implements
        PrimitiveSerializer<FontSubmissionDtoAuthorizationRuleVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'adminFontUploadV1': 'admin-font-upload-v1',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'admin-font-upload-v1': 'adminFontUploadV1',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    FontSubmissionDtoAuthorizationRuleVersionEnum,
  ];
  @override
  final String wireName = 'FontSubmissionDtoAuthorizationRuleVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontSubmissionDtoAuthorizationRuleVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontSubmissionDtoAuthorizationRuleVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontSubmissionDtoAuthorizationRuleVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontSubmissionDto extends FontSubmissionDto {
  @override
  final String submissionId;
  @override
  final String familyId;
  @override
  final int familyRevision;
  @override
  final String name;
  @override
  final FontSubmissionDtoLanguageEnum language;
  @override
  final int sortOrder;
  @override
  final FontSubmissionDtoAuthorizationRuleVersionEnum authorizationRuleVersion;
  @override
  final FontJobDto? job;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$FontSubmissionDto([
    void Function(FontSubmissionDtoBuilder)? updates,
  ]) => (FontSubmissionDtoBuilder()..update(updates))._build();

  _$FontSubmissionDto._({
    required this.submissionId,
    required this.familyId,
    required this.familyRevision,
    required this.name,
    required this.language,
    required this.sortOrder,
    required this.authorizationRuleVersion,
    this.job,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();
  @override
  FontSubmissionDto rebuild(void Function(FontSubmissionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontSubmissionDtoBuilder toBuilder() =>
      FontSubmissionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontSubmissionDto &&
        submissionId == other.submissionId &&
        familyId == other.familyId &&
        familyRevision == other.familyRevision &&
        name == other.name &&
        language == other.language &&
        sortOrder == other.sortOrder &&
        authorizationRuleVersion == other.authorizationRuleVersion &&
        job == other.job &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, submissionId.hashCode);
    _$hash = $jc(_$hash, familyId.hashCode);
    _$hash = $jc(_$hash, familyRevision.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, authorizationRuleVersion.hashCode);
    _$hash = $jc(_$hash, job.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontSubmissionDto')
          ..add('submissionId', submissionId)
          ..add('familyId', familyId)
          ..add('familyRevision', familyRevision)
          ..add('name', name)
          ..add('language', language)
          ..add('sortOrder', sortOrder)
          ..add('authorizationRuleVersion', authorizationRuleVersion)
          ..add('job', job)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class FontSubmissionDtoBuilder
    implements Builder<FontSubmissionDto, FontSubmissionDtoBuilder> {
  _$FontSubmissionDto? _$v;

  String? _submissionId;
  String? get submissionId => _$this._submissionId;
  set submissionId(String? submissionId) => _$this._submissionId = submissionId;

  String? _familyId;
  String? get familyId => _$this._familyId;
  set familyId(String? familyId) => _$this._familyId = familyId;

  int? _familyRevision;
  int? get familyRevision => _$this._familyRevision;
  set familyRevision(int? familyRevision) =>
      _$this._familyRevision = familyRevision;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  FontSubmissionDtoLanguageEnum? _language;
  FontSubmissionDtoLanguageEnum? get language => _$this._language;
  set language(FontSubmissionDtoLanguageEnum? language) =>
      _$this._language = language;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  FontSubmissionDtoAuthorizationRuleVersionEnum? _authorizationRuleVersion;
  FontSubmissionDtoAuthorizationRuleVersionEnum? get authorizationRuleVersion =>
      _$this._authorizationRuleVersion;
  set authorizationRuleVersion(
    FontSubmissionDtoAuthorizationRuleVersionEnum? authorizationRuleVersion,
  ) => _$this._authorizationRuleVersion = authorizationRuleVersion;

  FontJobDtoBuilder? _job;
  FontJobDtoBuilder get job => _$this._job ??= FontJobDtoBuilder();
  set job(FontJobDtoBuilder? job) => _$this._job = job;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  FontSubmissionDtoBuilder() {
    FontSubmissionDto._defaults(this);
  }

  FontSubmissionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _submissionId = $v.submissionId;
      _familyId = $v.familyId;
      _familyRevision = $v.familyRevision;
      _name = $v.name;
      _language = $v.language;
      _sortOrder = $v.sortOrder;
      _authorizationRuleVersion = $v.authorizationRuleVersion;
      _job = $v.job?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontSubmissionDto other) {
    _$v = other as _$FontSubmissionDto;
  }

  @override
  void update(void Function(FontSubmissionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontSubmissionDto build() => _build();

  _$FontSubmissionDto _build() {
    _$FontSubmissionDto _$result;
    try {
      _$result =
          _$v ??
          _$FontSubmissionDto._(
            submissionId: BuiltValueNullFieldError.checkNotNull(
              submissionId,
              r'FontSubmissionDto',
              'submissionId',
            ),
            familyId: BuiltValueNullFieldError.checkNotNull(
              familyId,
              r'FontSubmissionDto',
              'familyId',
            ),
            familyRevision: BuiltValueNullFieldError.checkNotNull(
              familyRevision,
              r'FontSubmissionDto',
              'familyRevision',
            ),
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'FontSubmissionDto',
              'name',
            ),
            language: BuiltValueNullFieldError.checkNotNull(
              language,
              r'FontSubmissionDto',
              'language',
            ),
            sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'FontSubmissionDto',
              'sortOrder',
            ),
            authorizationRuleVersion: BuiltValueNullFieldError.checkNotNull(
              authorizationRuleVersion,
              r'FontSubmissionDto',
              'authorizationRuleVersion',
            ),
            job: _job?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'FontSubmissionDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'FontSubmissionDto',
              'updatedAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'job';
        _job?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontSubmissionDto',
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
