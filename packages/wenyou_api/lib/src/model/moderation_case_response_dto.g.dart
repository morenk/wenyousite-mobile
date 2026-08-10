// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_case_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ModerationCaseResponseDtoTargetTypeEnum
_$moderationCaseResponseDtoTargetTypeEnum_USER =
    const ModerationCaseResponseDtoTargetTypeEnum._('USER');
const ModerationCaseResponseDtoTargetTypeEnum
_$moderationCaseResponseDtoTargetTypeEnum_THREAD =
    const ModerationCaseResponseDtoTargetTypeEnum._('THREAD');
const ModerationCaseResponseDtoTargetTypeEnum
_$moderationCaseResponseDtoTargetTypeEnum_POST =
    const ModerationCaseResponseDtoTargetTypeEnum._('POST');
const ModerationCaseResponseDtoTargetTypeEnum
_$moderationCaseResponseDtoTargetTypeEnum_MOMENT =
    const ModerationCaseResponseDtoTargetTypeEnum._('MOMENT');
const ModerationCaseResponseDtoTargetTypeEnum
_$moderationCaseResponseDtoTargetTypeEnum_MOMENT_COMMENT =
    const ModerationCaseResponseDtoTargetTypeEnum._('MOMENT_COMMENT');
const ModerationCaseResponseDtoTargetTypeEnum
_$moderationCaseResponseDtoTargetTypeEnum_DIRECT_MESSAGE =
    const ModerationCaseResponseDtoTargetTypeEnum._('DIRECT_MESSAGE');
const ModerationCaseResponseDtoTargetTypeEnum
_$moderationCaseResponseDtoTargetTypeEnum_unknownDefaultOpenApi =
    const ModerationCaseResponseDtoTargetTypeEnum._('unknownDefaultOpenApi');

ModerationCaseResponseDtoTargetTypeEnum
_$moderationCaseResponseDtoTargetTypeEnumValueOf(String name) {
  switch (name) {
    case 'USER':
      return _$moderationCaseResponseDtoTargetTypeEnum_USER;
    case 'THREAD':
      return _$moderationCaseResponseDtoTargetTypeEnum_THREAD;
    case 'POST':
      return _$moderationCaseResponseDtoTargetTypeEnum_POST;
    case 'MOMENT':
      return _$moderationCaseResponseDtoTargetTypeEnum_MOMENT;
    case 'MOMENT_COMMENT':
      return _$moderationCaseResponseDtoTargetTypeEnum_MOMENT_COMMENT;
    case 'DIRECT_MESSAGE':
      return _$moderationCaseResponseDtoTargetTypeEnum_DIRECT_MESSAGE;
    case 'unknownDefaultOpenApi':
      return _$moderationCaseResponseDtoTargetTypeEnum_unknownDefaultOpenApi;
    default:
      return _$moderationCaseResponseDtoTargetTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ModerationCaseResponseDtoTargetTypeEnum>
_$moderationCaseResponseDtoTargetTypeEnumValues =
    BuiltSet<ModerationCaseResponseDtoTargetTypeEnum>(
      const <ModerationCaseResponseDtoTargetTypeEnum>[
        _$moderationCaseResponseDtoTargetTypeEnum_USER,
        _$moderationCaseResponseDtoTargetTypeEnum_THREAD,
        _$moderationCaseResponseDtoTargetTypeEnum_POST,
        _$moderationCaseResponseDtoTargetTypeEnum_MOMENT,
        _$moderationCaseResponseDtoTargetTypeEnum_MOMENT_COMMENT,
        _$moderationCaseResponseDtoTargetTypeEnum_DIRECT_MESSAGE,
        _$moderationCaseResponseDtoTargetTypeEnum_unknownDefaultOpenApi,
      ],
    );

const ModerationCaseResponseDtoStatusEnum
_$moderationCaseResponseDtoStatusEnum_OPEN =
    const ModerationCaseResponseDtoStatusEnum._('OPEN');
const ModerationCaseResponseDtoStatusEnum
_$moderationCaseResponseDtoStatusEnum_RESOLVED =
    const ModerationCaseResponseDtoStatusEnum._('RESOLVED');
const ModerationCaseResponseDtoStatusEnum
_$moderationCaseResponseDtoStatusEnum_DISMISSED =
    const ModerationCaseResponseDtoStatusEnum._('DISMISSED');
const ModerationCaseResponseDtoStatusEnum
_$moderationCaseResponseDtoStatusEnum_unknownDefaultOpenApi =
    const ModerationCaseResponseDtoStatusEnum._('unknownDefaultOpenApi');

ModerationCaseResponseDtoStatusEnum
_$moderationCaseResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'OPEN':
      return _$moderationCaseResponseDtoStatusEnum_OPEN;
    case 'RESOLVED':
      return _$moderationCaseResponseDtoStatusEnum_RESOLVED;
    case 'DISMISSED':
      return _$moderationCaseResponseDtoStatusEnum_DISMISSED;
    case 'unknownDefaultOpenApi':
      return _$moderationCaseResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$moderationCaseResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ModerationCaseResponseDtoStatusEnum>
_$moderationCaseResponseDtoStatusEnumValues =
    BuiltSet<ModerationCaseResponseDtoStatusEnum>(
      const <ModerationCaseResponseDtoStatusEnum>[
        _$moderationCaseResponseDtoStatusEnum_OPEN,
        _$moderationCaseResponseDtoStatusEnum_RESOLVED,
        _$moderationCaseResponseDtoStatusEnum_DISMISSED,
        _$moderationCaseResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ModerationCaseResponseDtoTargetTypeEnum>
_$moderationCaseResponseDtoTargetTypeEnumSerializer =
    _$ModerationCaseResponseDtoTargetTypeEnumSerializer();
Serializer<ModerationCaseResponseDtoStatusEnum>
_$moderationCaseResponseDtoStatusEnumSerializer =
    _$ModerationCaseResponseDtoStatusEnumSerializer();

class _$ModerationCaseResponseDtoTargetTypeEnumSerializer
    implements PrimitiveSerializer<ModerationCaseResponseDtoTargetTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'USER': 'USER',
    'THREAD': 'THREAD',
    'POST': 'POST',
    'MOMENT': 'MOMENT',
    'MOMENT_COMMENT': 'MOMENT_COMMENT',
    'DIRECT_MESSAGE': 'DIRECT_MESSAGE',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'USER': 'USER',
    'THREAD': 'THREAD',
    'POST': 'POST',
    'MOMENT': 'MOMENT',
    'MOMENT_COMMENT': 'MOMENT_COMMENT',
    'DIRECT_MESSAGE': 'DIRECT_MESSAGE',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ModerationCaseResponseDtoTargetTypeEnum,
  ];
  @override
  final String wireName = 'ModerationCaseResponseDtoTargetTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ModerationCaseResponseDtoTargetTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ModerationCaseResponseDtoTargetTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ModerationCaseResponseDtoTargetTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ModerationCaseResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<ModerationCaseResponseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'OPEN': 'OPEN',
    'RESOLVED': 'RESOLVED',
    'DISMISSED': 'DISMISSED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'OPEN': 'OPEN',
    'RESOLVED': 'RESOLVED',
    'DISMISSED': 'DISMISSED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ModerationCaseResponseDtoStatusEnum,
  ];
  @override
  final String wireName = 'ModerationCaseResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    ModerationCaseResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ModerationCaseResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ModerationCaseResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ModerationCaseResponseDto extends ModerationCaseResponseDto {
  @override
  final String id;
  @override
  final ModerationCaseResponseDtoTargetTypeEnum targetType;
  @override
  final String targetId;
  @override
  final ModerationCaseResponseDtoStatusEnum status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>> reports;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>> decisions;

  factory _$ModerationCaseResponseDto([
    void Function(ModerationCaseResponseDtoBuilder)? updates,
  ]) => (ModerationCaseResponseDtoBuilder()..update(updates))._build();

  _$ModerationCaseResponseDto._({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.reports,
    required this.decisions,
  }) : super._();
  @override
  ModerationCaseResponseDto rebuild(
    void Function(ModerationCaseResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ModerationCaseResponseDtoBuilder toBuilder() =>
      ModerationCaseResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModerationCaseResponseDto &&
        id == other.id &&
        targetType == other.targetType &&
        targetId == other.targetId &&
        status == other.status &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        reports == other.reports &&
        decisions == other.decisions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, targetType.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, reports.hashCode);
    _$hash = $jc(_$hash, decisions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ModerationCaseResponseDto')
          ..add('id', id)
          ..add('targetType', targetType)
          ..add('targetId', targetId)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('reports', reports)
          ..add('decisions', decisions))
        .toString();
  }
}

class ModerationCaseResponseDtoBuilder
    implements
        Builder<ModerationCaseResponseDto, ModerationCaseResponseDtoBuilder> {
  _$ModerationCaseResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ModerationCaseResponseDtoTargetTypeEnum? _targetType;
  ModerationCaseResponseDtoTargetTypeEnum? get targetType => _$this._targetType;
  set targetType(ModerationCaseResponseDtoTargetTypeEnum? targetType) =>
      _$this._targetType = targetType;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  ModerationCaseResponseDtoStatusEnum? _status;
  ModerationCaseResponseDtoStatusEnum? get status => _$this._status;
  set status(ModerationCaseResponseDtoStatusEnum? status) =>
      _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ListBuilder<BuiltMap<String, JsonObject?>>? _reports;
  ListBuilder<BuiltMap<String, JsonObject?>> get reports =>
      _$this._reports ??= ListBuilder<BuiltMap<String, JsonObject?>>();
  set reports(ListBuilder<BuiltMap<String, JsonObject?>>? reports) =>
      _$this._reports = reports;

  ListBuilder<BuiltMap<String, JsonObject?>>? _decisions;
  ListBuilder<BuiltMap<String, JsonObject?>> get decisions =>
      _$this._decisions ??= ListBuilder<BuiltMap<String, JsonObject?>>();
  set decisions(ListBuilder<BuiltMap<String, JsonObject?>>? decisions) =>
      _$this._decisions = decisions;

  ModerationCaseResponseDtoBuilder() {
    ModerationCaseResponseDto._defaults(this);
  }

  ModerationCaseResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _targetType = $v.targetType;
      _targetId = $v.targetId;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _reports = $v.reports.toBuilder();
      _decisions = $v.decisions.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModerationCaseResponseDto other) {
    _$v = other as _$ModerationCaseResponseDto;
  }

  @override
  void update(void Function(ModerationCaseResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModerationCaseResponseDto build() => _build();

  _$ModerationCaseResponseDto _build() {
    _$ModerationCaseResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ModerationCaseResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'ModerationCaseResponseDto',
              'id',
            ),
            targetType: BuiltValueNullFieldError.checkNotNull(
              targetType,
              r'ModerationCaseResponseDto',
              'targetType',
            ),
            targetId: BuiltValueNullFieldError.checkNotNull(
              targetId,
              r'ModerationCaseResponseDto',
              'targetId',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'ModerationCaseResponseDto',
              'status',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'ModerationCaseResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'ModerationCaseResponseDto',
              'updatedAt',
            ),
            reports: reports.build(),
            decisions: decisions.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'reports';
        reports.build();
        _$failedField = 'decisions';
        decisions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ModerationCaseResponseDto',
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
