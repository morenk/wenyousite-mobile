// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_subscription_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateSubscriptionDtoTypeEnum _$createSubscriptionDtoTypeEnum_THREAD =
    const CreateSubscriptionDtoTypeEnum._('THREAD');
const CreateSubscriptionDtoTypeEnum _$createSubscriptionDtoTypeEnum_USER =
    const CreateSubscriptionDtoTypeEnum._('USER');
const CreateSubscriptionDtoTypeEnum
_$createSubscriptionDtoTypeEnum_unknownDefaultOpenApi =
    const CreateSubscriptionDtoTypeEnum._('unknownDefaultOpenApi');

CreateSubscriptionDtoTypeEnum _$createSubscriptionDtoTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'THREAD':
      return _$createSubscriptionDtoTypeEnum_THREAD;
    case 'USER':
      return _$createSubscriptionDtoTypeEnum_USER;
    case 'unknownDefaultOpenApi':
      return _$createSubscriptionDtoTypeEnum_unknownDefaultOpenApi;
    default:
      return _$createSubscriptionDtoTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CreateSubscriptionDtoTypeEnum>
_$createSubscriptionDtoTypeEnumValues = BuiltSet<CreateSubscriptionDtoTypeEnum>(
  const <CreateSubscriptionDtoTypeEnum>[
    _$createSubscriptionDtoTypeEnum_THREAD,
    _$createSubscriptionDtoTypeEnum_USER,
    _$createSubscriptionDtoTypeEnum_unknownDefaultOpenApi,
  ],
);

Serializer<CreateSubscriptionDtoTypeEnum>
_$createSubscriptionDtoTypeEnumSerializer =
    _$CreateSubscriptionDtoTypeEnumSerializer();

class _$CreateSubscriptionDtoTypeEnumSerializer
    implements PrimitiveSerializer<CreateSubscriptionDtoTypeEnum> {
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
  final Iterable<Type> types = const <Type>[CreateSubscriptionDtoTypeEnum];
  @override
  final String wireName = 'CreateSubscriptionDtoTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreateSubscriptionDtoTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreateSubscriptionDtoTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreateSubscriptionDtoTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreateSubscriptionDto extends CreateSubscriptionDto {
  @override
  final String threadId;
  @override
  final CreateSubscriptionDtoTypeEnum type;
  @override
  final String? targetUserId;

  factory _$CreateSubscriptionDto([
    void Function(CreateSubscriptionDtoBuilder)? updates,
  ]) => (CreateSubscriptionDtoBuilder()..update(updates))._build();

  _$CreateSubscriptionDto._({
    required this.threadId,
    required this.type,
    this.targetUserId,
  }) : super._();
  @override
  CreateSubscriptionDto rebuild(
    void Function(CreateSubscriptionDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateSubscriptionDtoBuilder toBuilder() =>
      CreateSubscriptionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateSubscriptionDto &&
        threadId == other.threadId &&
        type == other.type &&
        targetUserId == other.targetUserId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, targetUserId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateSubscriptionDto')
          ..add('threadId', threadId)
          ..add('type', type)
          ..add('targetUserId', targetUserId))
        .toString();
  }
}

class CreateSubscriptionDtoBuilder
    implements Builder<CreateSubscriptionDto, CreateSubscriptionDtoBuilder> {
  _$CreateSubscriptionDto? _$v;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  CreateSubscriptionDtoTypeEnum? _type;
  CreateSubscriptionDtoTypeEnum? get type => _$this._type;
  set type(CreateSubscriptionDtoTypeEnum? type) => _$this._type = type;

  String? _targetUserId;
  String? get targetUserId => _$this._targetUserId;
  set targetUserId(String? targetUserId) => _$this._targetUserId = targetUserId;

  CreateSubscriptionDtoBuilder() {
    CreateSubscriptionDto._defaults(this);
  }

  CreateSubscriptionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _threadId = $v.threadId;
      _type = $v.type;
      _targetUserId = $v.targetUserId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateSubscriptionDto other) {
    _$v = other as _$CreateSubscriptionDto;
  }

  @override
  void update(void Function(CreateSubscriptionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateSubscriptionDto build() => _build();

  _$CreateSubscriptionDto _build() {
    final _$result =
        _$v ??
        _$CreateSubscriptionDto._(
          threadId: BuiltValueNullFieldError.checkNotNull(
            threadId,
            r'CreateSubscriptionDto',
            'threadId',
          ),
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'CreateSubscriptionDto',
            'type',
          ),
          targetUserId: targetUserId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
