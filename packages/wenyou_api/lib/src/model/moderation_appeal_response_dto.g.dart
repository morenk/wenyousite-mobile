// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_appeal_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ModerationAppealResponseDtoStatusEnum
_$moderationAppealResponseDtoStatusEnum_PENDING =
    const ModerationAppealResponseDtoStatusEnum._('PENDING');
const ModerationAppealResponseDtoStatusEnum
_$moderationAppealResponseDtoStatusEnum_UPHELD =
    const ModerationAppealResponseDtoStatusEnum._('UPHELD');
const ModerationAppealResponseDtoStatusEnum
_$moderationAppealResponseDtoStatusEnum_OVERTURNED =
    const ModerationAppealResponseDtoStatusEnum._('OVERTURNED');
const ModerationAppealResponseDtoStatusEnum
_$moderationAppealResponseDtoStatusEnum_unknownDefaultOpenApi =
    const ModerationAppealResponseDtoStatusEnum._('unknownDefaultOpenApi');

ModerationAppealResponseDtoStatusEnum
_$moderationAppealResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$moderationAppealResponseDtoStatusEnum_PENDING;
    case 'UPHELD':
      return _$moderationAppealResponseDtoStatusEnum_UPHELD;
    case 'OVERTURNED':
      return _$moderationAppealResponseDtoStatusEnum_OVERTURNED;
    case 'unknownDefaultOpenApi':
      return _$moderationAppealResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$moderationAppealResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ModerationAppealResponseDtoStatusEnum>
_$moderationAppealResponseDtoStatusEnumValues =
    BuiltSet<ModerationAppealResponseDtoStatusEnum>(
      const <ModerationAppealResponseDtoStatusEnum>[
        _$moderationAppealResponseDtoStatusEnum_PENDING,
        _$moderationAppealResponseDtoStatusEnum_UPHELD,
        _$moderationAppealResponseDtoStatusEnum_OVERTURNED,
        _$moderationAppealResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ModerationAppealResponseDtoStatusEnum>
_$moderationAppealResponseDtoStatusEnumSerializer =
    _$ModerationAppealResponseDtoStatusEnumSerializer();

class _$ModerationAppealResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<ModerationAppealResponseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'UPHELD': 'UPHELD',
    'OVERTURNED': 'OVERTURNED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'UPHELD': 'UPHELD',
    'OVERTURNED': 'OVERTURNED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ModerationAppealResponseDtoStatusEnum,
  ];
  @override
  final String wireName = 'ModerationAppealResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    ModerationAppealResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ModerationAppealResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ModerationAppealResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ModerationAppealResponseDto extends ModerationAppealResponseDto {
  @override
  final String id;
  @override
  final String statement;
  @override
  final ModerationAppealResponseDtoStatusEnum status;
  @override
  final ModerationAppealDecisionResponseDto decision;
  @override
  final ModerationAppealAppellantResponseDto appellant;
  @override
  final DateTime createdAt;

  factory _$ModerationAppealResponseDto([
    void Function(ModerationAppealResponseDtoBuilder)? updates,
  ]) => (ModerationAppealResponseDtoBuilder()..update(updates))._build();

  _$ModerationAppealResponseDto._({
    required this.id,
    required this.statement,
    required this.status,
    required this.decision,
    required this.appellant,
    required this.createdAt,
  }) : super._();
  @override
  ModerationAppealResponseDto rebuild(
    void Function(ModerationAppealResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ModerationAppealResponseDtoBuilder toBuilder() =>
      ModerationAppealResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModerationAppealResponseDto &&
        id == other.id &&
        statement == other.statement &&
        status == other.status &&
        decision == other.decision &&
        appellant == other.appellant &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, statement.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, decision.hashCode);
    _$hash = $jc(_$hash, appellant.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ModerationAppealResponseDto')
          ..add('id', id)
          ..add('statement', statement)
          ..add('status', status)
          ..add('decision', decision)
          ..add('appellant', appellant)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ModerationAppealResponseDtoBuilder
    implements
        Builder<
          ModerationAppealResponseDto,
          ModerationAppealResponseDtoBuilder
        > {
  _$ModerationAppealResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _statement;
  String? get statement => _$this._statement;
  set statement(String? statement) => _$this._statement = statement;

  ModerationAppealResponseDtoStatusEnum? _status;
  ModerationAppealResponseDtoStatusEnum? get status => _$this._status;
  set status(ModerationAppealResponseDtoStatusEnum? status) =>
      _$this._status = status;

  ModerationAppealDecisionResponseDtoBuilder? _decision;
  ModerationAppealDecisionResponseDtoBuilder get decision =>
      _$this._decision ??= ModerationAppealDecisionResponseDtoBuilder();
  set decision(ModerationAppealDecisionResponseDtoBuilder? decision) =>
      _$this._decision = decision;

  ModerationAppealAppellantResponseDtoBuilder? _appellant;
  ModerationAppealAppellantResponseDtoBuilder get appellant =>
      _$this._appellant ??= ModerationAppealAppellantResponseDtoBuilder();
  set appellant(ModerationAppealAppellantResponseDtoBuilder? appellant) =>
      _$this._appellant = appellant;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ModerationAppealResponseDtoBuilder() {
    ModerationAppealResponseDto._defaults(this);
  }

  ModerationAppealResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _statement = $v.statement;
      _status = $v.status;
      _decision = $v.decision.toBuilder();
      _appellant = $v.appellant.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModerationAppealResponseDto other) {
    _$v = other as _$ModerationAppealResponseDto;
  }

  @override
  void update(void Function(ModerationAppealResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModerationAppealResponseDto build() => _build();

  _$ModerationAppealResponseDto _build() {
    _$ModerationAppealResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ModerationAppealResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'ModerationAppealResponseDto',
              'id',
            ),
            statement: BuiltValueNullFieldError.checkNotNull(
              statement,
              r'ModerationAppealResponseDto',
              'statement',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'ModerationAppealResponseDto',
              'status',
            ),
            decision: decision.build(),
            appellant: appellant.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'ModerationAppealResponseDto',
              'createdAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'decision';
        decision.build();
        _$failedField = 'appellant';
        appellant.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ModerationAppealResponseDto',
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
