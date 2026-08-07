// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubscriptionResponseDtoTypeEnum _$subscriptionResponseDtoTypeEnum_THREAD =
    const SubscriptionResponseDtoTypeEnum._('THREAD');
const SubscriptionResponseDtoTypeEnum _$subscriptionResponseDtoTypeEnum_USER =
    const SubscriptionResponseDtoTypeEnum._('USER');
const SubscriptionResponseDtoTypeEnum
_$subscriptionResponseDtoTypeEnum_unknownDefaultOpenApi =
    const SubscriptionResponseDtoTypeEnum._('unknownDefaultOpenApi');

SubscriptionResponseDtoTypeEnum _$subscriptionResponseDtoTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'THREAD':
      return _$subscriptionResponseDtoTypeEnum_THREAD;
    case 'USER':
      return _$subscriptionResponseDtoTypeEnum_USER;
    case 'unknownDefaultOpenApi':
      return _$subscriptionResponseDtoTypeEnum_unknownDefaultOpenApi;
    default:
      return _$subscriptionResponseDtoTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubscriptionResponseDtoTypeEnum>
_$subscriptionResponseDtoTypeEnumValues =
    BuiltSet<SubscriptionResponseDtoTypeEnum>(
      const <SubscriptionResponseDtoTypeEnum>[
        _$subscriptionResponseDtoTypeEnum_THREAD,
        _$subscriptionResponseDtoTypeEnum_USER,
        _$subscriptionResponseDtoTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubscriptionResponseDtoTypeEnum>
_$subscriptionResponseDtoTypeEnumSerializer =
    _$SubscriptionResponseDtoTypeEnumSerializer();

class _$SubscriptionResponseDtoTypeEnumSerializer
    implements PrimitiveSerializer<SubscriptionResponseDtoTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'THREAD': 'THREAD',
    'USER': 'USER',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'THREAD': 'THREAD',
    'USER': 'USER',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[SubscriptionResponseDtoTypeEnum];
  @override
  final String wireName = 'SubscriptionResponseDtoTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionResponseDtoTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubscriptionResponseDtoTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubscriptionResponseDtoTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubscriptionResponseDto extends SubscriptionResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String threadId;
  @override
  final String? targetUserId;
  @override
  final SubscriptionResponseDtoTypeEnum type;
  @override
  final DateTime createdAt;
  @override
  final SubscriptionThreadResponseDto thread;

  factory _$SubscriptionResponseDto([
    void Function(SubscriptionResponseDtoBuilder)? updates,
  ]) => (SubscriptionResponseDtoBuilder()..update(updates))._build();

  _$SubscriptionResponseDto._({
    required this.id,
    required this.userId,
    required this.threadId,
    this.targetUserId,
    required this.type,
    required this.createdAt,
    required this.thread,
  }) : super._();
  @override
  SubscriptionResponseDto rebuild(
    void Function(SubscriptionResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubscriptionResponseDtoBuilder toBuilder() =>
      SubscriptionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubscriptionResponseDto &&
        id == other.id &&
        userId == other.userId &&
        threadId == other.threadId &&
        targetUserId == other.targetUserId &&
        type == other.type &&
        createdAt == other.createdAt &&
        thread == other.thread;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, targetUserId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, thread.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubscriptionResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('threadId', threadId)
          ..add('targetUserId', targetUserId)
          ..add('type', type)
          ..add('createdAt', createdAt)
          ..add('thread', thread))
        .toString();
  }
}

class SubscriptionResponseDtoBuilder
    implements
        Builder<SubscriptionResponseDto, SubscriptionResponseDtoBuilder> {
  _$SubscriptionResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _targetUserId;
  String? get targetUserId => _$this._targetUserId;
  set targetUserId(String? targetUserId) => _$this._targetUserId = targetUserId;

  SubscriptionResponseDtoTypeEnum? _type;
  SubscriptionResponseDtoTypeEnum? get type => _$this._type;
  set type(SubscriptionResponseDtoTypeEnum? type) => _$this._type = type;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  SubscriptionThreadResponseDtoBuilder? _thread;
  SubscriptionThreadResponseDtoBuilder get thread =>
      _$this._thread ??= SubscriptionThreadResponseDtoBuilder();
  set thread(SubscriptionThreadResponseDtoBuilder? thread) =>
      _$this._thread = thread;

  SubscriptionResponseDtoBuilder() {
    SubscriptionResponseDto._defaults(this);
  }

  SubscriptionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _threadId = $v.threadId;
      _targetUserId = $v.targetUserId;
      _type = $v.type;
      _createdAt = $v.createdAt;
      _thread = $v.thread.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubscriptionResponseDto other) {
    _$v = other as _$SubscriptionResponseDto;
  }

  @override
  void update(void Function(SubscriptionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubscriptionResponseDto build() => _build();

  _$SubscriptionResponseDto _build() {
    _$SubscriptionResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SubscriptionResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'SubscriptionResponseDto',
              'id',
            ),
            userId: BuiltValueNullFieldError.checkNotNull(
              userId,
              r'SubscriptionResponseDto',
              'userId',
            ),
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'SubscriptionResponseDto',
              'threadId',
            ),
            targetUserId: targetUserId,
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'SubscriptionResponseDto',
              'type',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'SubscriptionResponseDto',
              'createdAt',
            ),
            thread: thread.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'thread';
        thread.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SubscriptionResponseDto',
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
