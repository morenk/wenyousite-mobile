// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReportResponseDtoStatusEnum _$reportResponseDtoStatusEnum_PENDING =
    const ReportResponseDtoStatusEnum._('PENDING');
const ReportResponseDtoStatusEnum _$reportResponseDtoStatusEnum_RESOLVED =
    const ReportResponseDtoStatusEnum._('RESOLVED');
const ReportResponseDtoStatusEnum _$reportResponseDtoStatusEnum_DISMISSED =
    const ReportResponseDtoStatusEnum._('DISMISSED');
const ReportResponseDtoStatusEnum
_$reportResponseDtoStatusEnum_unknownDefaultOpenApi =
    const ReportResponseDtoStatusEnum._('unknownDefaultOpenApi');

ReportResponseDtoStatusEnum _$reportResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$reportResponseDtoStatusEnum_PENDING;
    case 'RESOLVED':
      return _$reportResponseDtoStatusEnum_RESOLVED;
    case 'DISMISSED':
      return _$reportResponseDtoStatusEnum_DISMISSED;
    case 'unknownDefaultOpenApi':
      return _$reportResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$reportResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ReportResponseDtoStatusEnum>
_$reportResponseDtoStatusEnumValues =
    BuiltSet<ReportResponseDtoStatusEnum>(const <ReportResponseDtoStatusEnum>[
      _$reportResponseDtoStatusEnum_PENDING,
      _$reportResponseDtoStatusEnum_RESOLVED,
      _$reportResponseDtoStatusEnum_DISMISSED,
      _$reportResponseDtoStatusEnum_unknownDefaultOpenApi,
    ]);

Serializer<ReportResponseDtoStatusEnum>
_$reportResponseDtoStatusEnumSerializer =
    _$ReportResponseDtoStatusEnumSerializer();

class _$ReportResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<ReportResponseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'RESOLVED': 'RESOLVED',
    'DISMISSED': 'DISMISSED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'RESOLVED': 'RESOLVED',
    'DISMISSED': 'DISMISSED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ReportResponseDtoStatusEnum];
  @override
  final String wireName = 'ReportResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    ReportResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ReportResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ReportResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ReportResponseDto extends ReportResponseDto {
  @override
  final String id;
  @override
  final String reporterId;
  @override
  final String targetType;
  @override
  final String targetId;
  @override
  final String reason;
  @override
  final ReportResponseDtoStatusEnum status;
  @override
  final String? handledBy;
  @override
  final DateTime? handledAt;
  @override
  final DateTime createdAt;

  factory _$ReportResponseDto([
    void Function(ReportResponseDtoBuilder)? updates,
  ]) => (ReportResponseDtoBuilder()..update(updates))._build();

  _$ReportResponseDto._({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    this.handledBy,
    this.handledAt,
    required this.createdAt,
  }) : super._();
  @override
  ReportResponseDto rebuild(void Function(ReportResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReportResponseDtoBuilder toBuilder() =>
      ReportResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportResponseDto &&
        id == other.id &&
        reporterId == other.reporterId &&
        targetType == other.targetType &&
        targetId == other.targetId &&
        reason == other.reason &&
        status == other.status &&
        handledBy == other.handledBy &&
        handledAt == other.handledAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, reporterId.hashCode);
    _$hash = $jc(_$hash, targetType.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, handledBy.hashCode);
    _$hash = $jc(_$hash, handledAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReportResponseDto')
          ..add('id', id)
          ..add('reporterId', reporterId)
          ..add('targetType', targetType)
          ..add('targetId', targetId)
          ..add('reason', reason)
          ..add('status', status)
          ..add('handledBy', handledBy)
          ..add('handledAt', handledAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ReportResponseDtoBuilder
    implements Builder<ReportResponseDto, ReportResponseDtoBuilder> {
  _$ReportResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _reporterId;
  String? get reporterId => _$this._reporterId;
  set reporterId(String? reporterId) => _$this._reporterId = reporterId;

  String? _targetType;
  String? get targetType => _$this._targetType;
  set targetType(String? targetType) => _$this._targetType = targetType;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ReportResponseDtoStatusEnum? _status;
  ReportResponseDtoStatusEnum? get status => _$this._status;
  set status(ReportResponseDtoStatusEnum? status) => _$this._status = status;

  String? _handledBy;
  String? get handledBy => _$this._handledBy;
  set handledBy(String? handledBy) => _$this._handledBy = handledBy;

  DateTime? _handledAt;
  DateTime? get handledAt => _$this._handledAt;
  set handledAt(DateTime? handledAt) => _$this._handledAt = handledAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ReportResponseDtoBuilder() {
    ReportResponseDto._defaults(this);
  }

  ReportResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _reporterId = $v.reporterId;
      _targetType = $v.targetType;
      _targetId = $v.targetId;
      _reason = $v.reason;
      _status = $v.status;
      _handledBy = $v.handledBy;
      _handledAt = $v.handledAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReportResponseDto other) {
    _$v = other as _$ReportResponseDto;
  }

  @override
  void update(void Function(ReportResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportResponseDto build() => _build();

  _$ReportResponseDto _build() {
    final _$result =
        _$v ??
        _$ReportResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ReportResponseDto',
            'id',
          ),
          reporterId: BuiltValueNullFieldError.checkNotNull(
            reporterId,
            r'ReportResponseDto',
            'reporterId',
          ),
          targetType: BuiltValueNullFieldError.checkNotNull(
            targetType,
            r'ReportResponseDto',
            'targetType',
          ),
          targetId: BuiltValueNullFieldError.checkNotNull(
            targetId,
            r'ReportResponseDto',
            'targetId',
          ),
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'ReportResponseDto',
            'reason',
          ),
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'ReportResponseDto',
            'status',
          ),
          handledBy: handledBy,
          handledAt: handledAt,
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'ReportResponseDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
