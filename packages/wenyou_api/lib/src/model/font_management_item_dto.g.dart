// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_management_item_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontManagementItemDtoLanguageEnum _$fontManagementItemDtoLanguageEnum_zh =
    const FontManagementItemDtoLanguageEnum._('zh');
const FontManagementItemDtoLanguageEnum _$fontManagementItemDtoLanguageEnum_ja =
    const FontManagementItemDtoLanguageEnum._('ja');
const FontManagementItemDtoLanguageEnum _$fontManagementItemDtoLanguageEnum_en =
    const FontManagementItemDtoLanguageEnum._('en');
const FontManagementItemDtoLanguageEnum
_$fontManagementItemDtoLanguageEnum_other =
    const FontManagementItemDtoLanguageEnum._('other');
const FontManagementItemDtoLanguageEnum
_$fontManagementItemDtoLanguageEnum_unknownDefaultOpenApi =
    const FontManagementItemDtoLanguageEnum._('unknownDefaultOpenApi');

FontManagementItemDtoLanguageEnum _$fontManagementItemDtoLanguageEnumValueOf(
  String name,
) {
  switch (name) {
    case 'zh':
      return _$fontManagementItemDtoLanguageEnum_zh;
    case 'ja':
      return _$fontManagementItemDtoLanguageEnum_ja;
    case 'en':
      return _$fontManagementItemDtoLanguageEnum_en;
    case 'other':
      return _$fontManagementItemDtoLanguageEnum_other;
    case 'unknownDefaultOpenApi':
      return _$fontManagementItemDtoLanguageEnum_unknownDefaultOpenApi;
    default:
      return _$fontManagementItemDtoLanguageEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontManagementItemDtoLanguageEnum>
_$fontManagementItemDtoLanguageEnumValues =
    BuiltSet<FontManagementItemDtoLanguageEnum>(
      const <FontManagementItemDtoLanguageEnum>[
        _$fontManagementItemDtoLanguageEnum_zh,
        _$fontManagementItemDtoLanguageEnum_ja,
        _$fontManagementItemDtoLanguageEnum_en,
        _$fontManagementItemDtoLanguageEnum_other,
        _$fontManagementItemDtoLanguageEnum_unknownDefaultOpenApi,
      ],
    );

const FontManagementItemDtoStatusEnum _$fontManagementItemDtoStatusEnum_draft =
    const FontManagementItemDtoStatusEnum._('draft');
const FontManagementItemDtoStatusEnum
_$fontManagementItemDtoStatusEnum_enabled =
    const FontManagementItemDtoStatusEnum._('enabled');
const FontManagementItemDtoStatusEnum
_$fontManagementItemDtoStatusEnum_disabled =
    const FontManagementItemDtoStatusEnum._('disabled');
const FontManagementItemDtoStatusEnum
_$fontManagementItemDtoStatusEnum_withdrawn =
    const FontManagementItemDtoStatusEnum._('withdrawn');
const FontManagementItemDtoStatusEnum
_$fontManagementItemDtoStatusEnum_unknownDefaultOpenApi =
    const FontManagementItemDtoStatusEnum._('unknownDefaultOpenApi');

FontManagementItemDtoStatusEnum _$fontManagementItemDtoStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'draft':
      return _$fontManagementItemDtoStatusEnum_draft;
    case 'enabled':
      return _$fontManagementItemDtoStatusEnum_enabled;
    case 'disabled':
      return _$fontManagementItemDtoStatusEnum_disabled;
    case 'withdrawn':
      return _$fontManagementItemDtoStatusEnum_withdrawn;
    case 'unknownDefaultOpenApi':
      return _$fontManagementItemDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$fontManagementItemDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontManagementItemDtoStatusEnum>
_$fontManagementItemDtoStatusEnumValues =
    BuiltSet<FontManagementItemDtoStatusEnum>(
      const <FontManagementItemDtoStatusEnum>[
        _$fontManagementItemDtoStatusEnum_draft,
        _$fontManagementItemDtoStatusEnum_enabled,
        _$fontManagementItemDtoStatusEnum_disabled,
        _$fontManagementItemDtoStatusEnum_withdrawn,
        _$fontManagementItemDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<FontManagementItemDtoLanguageEnum>
_$fontManagementItemDtoLanguageEnumSerializer =
    _$FontManagementItemDtoLanguageEnumSerializer();
Serializer<FontManagementItemDtoStatusEnum>
_$fontManagementItemDtoStatusEnumSerializer =
    _$FontManagementItemDtoStatusEnumSerializer();

class _$FontManagementItemDtoLanguageEnumSerializer
    implements PrimitiveSerializer<FontManagementItemDtoLanguageEnum> {
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
  final Iterable<Type> types = const <Type>[FontManagementItemDtoLanguageEnum];
  @override
  final String wireName = 'FontManagementItemDtoLanguageEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontManagementItemDtoLanguageEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontManagementItemDtoLanguageEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontManagementItemDtoLanguageEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontManagementItemDtoStatusEnumSerializer
    implements PrimitiveSerializer<FontManagementItemDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'enabled': 'enabled',
    'disabled': 'disabled',
    'withdrawn': 'withdrawn',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'enabled': 'enabled',
    'disabled': 'disabled',
    'withdrawn': 'withdrawn',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[FontManagementItemDtoStatusEnum];
  @override
  final String wireName = 'FontManagementItemDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontManagementItemDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontManagementItemDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontManagementItemDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontManagementItemDto extends FontManagementItemDto {
  @override
  final String familyId;
  @override
  final String name;
  @override
  final FontManagementItemDtoLanguageEnum language;
  @override
  final int sortOrder;
  @override
  final int revision;
  @override
  final bool enabled;
  @override
  final FontManagementItemDtoStatusEnum status;
  @override
  final String? currentVersionId;
  @override
  final String? lastPublishedVersionId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? publishedAt;
  @override
  final DateTime? withdrawnAt;
  @override
  final FontJobDto? latestJob;
  @override
  final String? latestSubmissionId;

  factory _$FontManagementItemDto([
    void Function(FontManagementItemDtoBuilder)? updates,
  ]) => (FontManagementItemDtoBuilder()..update(updates))._build();

  _$FontManagementItemDto._({
    required this.familyId,
    required this.name,
    required this.language,
    required this.sortOrder,
    required this.revision,
    required this.enabled,
    required this.status,
    this.currentVersionId,
    this.lastPublishedVersionId,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.withdrawnAt,
    this.latestJob,
    this.latestSubmissionId,
  }) : super._();
  @override
  FontManagementItemDto rebuild(
    void Function(FontManagementItemDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontManagementItemDtoBuilder toBuilder() =>
      FontManagementItemDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontManagementItemDto &&
        familyId == other.familyId &&
        name == other.name &&
        language == other.language &&
        sortOrder == other.sortOrder &&
        revision == other.revision &&
        enabled == other.enabled &&
        status == other.status &&
        currentVersionId == other.currentVersionId &&
        lastPublishedVersionId == other.lastPublishedVersionId &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        publishedAt == other.publishedAt &&
        withdrawnAt == other.withdrawnAt &&
        latestJob == other.latestJob &&
        latestSubmissionId == other.latestSubmissionId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, familyId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, currentVersionId.hashCode);
    _$hash = $jc(_$hash, lastPublishedVersionId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, publishedAt.hashCode);
    _$hash = $jc(_$hash, withdrawnAt.hashCode);
    _$hash = $jc(_$hash, latestJob.hashCode);
    _$hash = $jc(_$hash, latestSubmissionId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontManagementItemDto')
          ..add('familyId', familyId)
          ..add('name', name)
          ..add('language', language)
          ..add('sortOrder', sortOrder)
          ..add('revision', revision)
          ..add('enabled', enabled)
          ..add('status', status)
          ..add('currentVersionId', currentVersionId)
          ..add('lastPublishedVersionId', lastPublishedVersionId)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('publishedAt', publishedAt)
          ..add('withdrawnAt', withdrawnAt)
          ..add('latestJob', latestJob)
          ..add('latestSubmissionId', latestSubmissionId))
        .toString();
  }
}

class FontManagementItemDtoBuilder
    implements Builder<FontManagementItemDto, FontManagementItemDtoBuilder> {
  _$FontManagementItemDto? _$v;

  String? _familyId;
  String? get familyId => _$this._familyId;
  set familyId(String? familyId) => _$this._familyId = familyId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  FontManagementItemDtoLanguageEnum? _language;
  FontManagementItemDtoLanguageEnum? get language => _$this._language;
  set language(FontManagementItemDtoLanguageEnum? language) =>
      _$this._language = language;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  FontManagementItemDtoStatusEnum? _status;
  FontManagementItemDtoStatusEnum? get status => _$this._status;
  set status(FontManagementItemDtoStatusEnum? status) =>
      _$this._status = status;

  String? _currentVersionId;
  String? get currentVersionId => _$this._currentVersionId;
  set currentVersionId(String? currentVersionId) =>
      _$this._currentVersionId = currentVersionId;

  String? _lastPublishedVersionId;
  String? get lastPublishedVersionId => _$this._lastPublishedVersionId;
  set lastPublishedVersionId(String? lastPublishedVersionId) =>
      _$this._lastPublishedVersionId = lastPublishedVersionId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _publishedAt;
  DateTime? get publishedAt => _$this._publishedAt;
  set publishedAt(DateTime? publishedAt) => _$this._publishedAt = publishedAt;

  DateTime? _withdrawnAt;
  DateTime? get withdrawnAt => _$this._withdrawnAt;
  set withdrawnAt(DateTime? withdrawnAt) => _$this._withdrawnAt = withdrawnAt;

  FontJobDtoBuilder? _latestJob;
  FontJobDtoBuilder get latestJob => _$this._latestJob ??= FontJobDtoBuilder();
  set latestJob(FontJobDtoBuilder? latestJob) => _$this._latestJob = latestJob;

  String? _latestSubmissionId;
  String? get latestSubmissionId => _$this._latestSubmissionId;
  set latestSubmissionId(String? latestSubmissionId) =>
      _$this._latestSubmissionId = latestSubmissionId;

  FontManagementItemDtoBuilder() {
    FontManagementItemDto._defaults(this);
  }

  FontManagementItemDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _familyId = $v.familyId;
      _name = $v.name;
      _language = $v.language;
      _sortOrder = $v.sortOrder;
      _revision = $v.revision;
      _enabled = $v.enabled;
      _status = $v.status;
      _currentVersionId = $v.currentVersionId;
      _lastPublishedVersionId = $v.lastPublishedVersionId;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _publishedAt = $v.publishedAt;
      _withdrawnAt = $v.withdrawnAt;
      _latestJob = $v.latestJob?.toBuilder();
      _latestSubmissionId = $v.latestSubmissionId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontManagementItemDto other) {
    _$v = other as _$FontManagementItemDto;
  }

  @override
  void update(void Function(FontManagementItemDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontManagementItemDto build() => _build();

  _$FontManagementItemDto _build() {
    _$FontManagementItemDto _$result;
    try {
      _$result =
          _$v ??
          _$FontManagementItemDto._(
            familyId: BuiltValueNullFieldError.checkNotNull(
              familyId,
              r'FontManagementItemDto',
              'familyId',
            ),
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'FontManagementItemDto',
              'name',
            ),
            language: BuiltValueNullFieldError.checkNotNull(
              language,
              r'FontManagementItemDto',
              'language',
            ),
            sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'FontManagementItemDto',
              'sortOrder',
            ),
            revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'FontManagementItemDto',
              'revision',
            ),
            enabled: BuiltValueNullFieldError.checkNotNull(
              enabled,
              r'FontManagementItemDto',
              'enabled',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'FontManagementItemDto',
              'status',
            ),
            currentVersionId: currentVersionId,
            lastPublishedVersionId: lastPublishedVersionId,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'FontManagementItemDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'FontManagementItemDto',
              'updatedAt',
            ),
            publishedAt: publishedAt,
            withdrawnAt: withdrawnAt,
            latestJob: _latestJob?.build(),
            latestSubmissionId: latestSubmissionId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'latestJob';
        _latestJob?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontManagementItemDto',
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
