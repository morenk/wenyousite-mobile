// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversation_lookup_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationLookupResponseDtoContactStateEnum
_$directConversationLookupResponseDtoContactStateEnum_NEW =
    const DirectConversationLookupResponseDtoContactStateEnum._('NEW');
const DirectConversationLookupResponseDtoContactStateEnum
_$directConversationLookupResponseDtoContactStateEnum_PENDING =
    const DirectConversationLookupResponseDtoContactStateEnum._('PENDING');
const DirectConversationLookupResponseDtoContactStateEnum
_$directConversationLookupResponseDtoContactStateEnum_ACCEPTED =
    const DirectConversationLookupResponseDtoContactStateEnum._('ACCEPTED');
const DirectConversationLookupResponseDtoContactStateEnum
_$directConversationLookupResponseDtoContactStateEnum_DECLINED =
    const DirectConversationLookupResponseDtoContactStateEnum._('DECLINED');
const DirectConversationLookupResponseDtoContactStateEnum
_$directConversationLookupResponseDtoContactStateEnum_CANCELED =
    const DirectConversationLookupResponseDtoContactStateEnum._('CANCELED');
const DirectConversationLookupResponseDtoContactStateEnum
_$directConversationLookupResponseDtoContactStateEnum_UNAVAILABLE =
    const DirectConversationLookupResponseDtoContactStateEnum._('UNAVAILABLE');
const DirectConversationLookupResponseDtoContactStateEnum
_$directConversationLookupResponseDtoContactStateEnum_unknownDefaultOpenApi =
    const DirectConversationLookupResponseDtoContactStateEnum._(
      'unknownDefaultOpenApi',
    );

DirectConversationLookupResponseDtoContactStateEnum
_$directConversationLookupResponseDtoContactStateEnumValueOf(String name) {
  switch (name) {
    case 'NEW':
      return _$directConversationLookupResponseDtoContactStateEnum_NEW;
    case 'PENDING':
      return _$directConversationLookupResponseDtoContactStateEnum_PENDING;
    case 'ACCEPTED':
      return _$directConversationLookupResponseDtoContactStateEnum_ACCEPTED;
    case 'DECLINED':
      return _$directConversationLookupResponseDtoContactStateEnum_DECLINED;
    case 'CANCELED':
      return _$directConversationLookupResponseDtoContactStateEnum_CANCELED;
    case 'UNAVAILABLE':
      return _$directConversationLookupResponseDtoContactStateEnum_UNAVAILABLE;
    case 'unknownDefaultOpenApi':
      return _$directConversationLookupResponseDtoContactStateEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationLookupResponseDtoContactStateEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationLookupResponseDtoContactStateEnum>
_$directConversationLookupResponseDtoContactStateEnumValues =
    BuiltSet<DirectConversationLookupResponseDtoContactStateEnum>(const <
      DirectConversationLookupResponseDtoContactStateEnum
    >[
      _$directConversationLookupResponseDtoContactStateEnum_NEW,
      _$directConversationLookupResponseDtoContactStateEnum_PENDING,
      _$directConversationLookupResponseDtoContactStateEnum_ACCEPTED,
      _$directConversationLookupResponseDtoContactStateEnum_DECLINED,
      _$directConversationLookupResponseDtoContactStateEnum_CANCELED,
      _$directConversationLookupResponseDtoContactStateEnum_UNAVAILABLE,
      _$directConversationLookupResponseDtoContactStateEnum_unknownDefaultOpenApi,
    ]);

Serializer<DirectConversationLookupResponseDtoContactStateEnum>
_$directConversationLookupResponseDtoContactStateEnumSerializer =
    _$DirectConversationLookupResponseDtoContactStateEnumSerializer();

class _$DirectConversationLookupResponseDtoContactStateEnumSerializer
    implements
        PrimitiveSerializer<
          DirectConversationLookupResponseDtoContactStateEnum
        > {
  static const Map<String, Object> _toWire = const <String, Object>{
    'NEW': 'NEW',
    'PENDING': 'PENDING',
    'ACCEPTED': 'ACCEPTED',
    'DECLINED': 'DECLINED',
    'CANCELED': 'CANCELED',
    'UNAVAILABLE': 'UNAVAILABLE',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'NEW': 'NEW',
    'PENDING': 'PENDING',
    'ACCEPTED': 'ACCEPTED',
    'DECLINED': 'DECLINED',
    'CANCELED': 'CANCELED',
    'UNAVAILABLE': 'UNAVAILABLE',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    DirectConversationLookupResponseDtoContactStateEnum,
  ];
  @override
  final String wireName = 'DirectConversationLookupResponseDtoContactStateEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationLookupResponseDtoContactStateEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationLookupResponseDtoContactStateEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationLookupResponseDtoContactStateEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationLookupResponseDto
    extends DirectConversationLookupResponseDto {
  @override
  final DirectConversationLookupResponseDtoContactStateEnum contactState;
  @override
  final bool canInitiate;
  @override
  final DirectConversationResponseDto? conversation;

  factory _$DirectConversationLookupResponseDto([
    void Function(DirectConversationLookupResponseDtoBuilder)? updates,
  ]) =>
      (DirectConversationLookupResponseDtoBuilder()..update(updates))._build();

  _$DirectConversationLookupResponseDto._({
    required this.contactState,
    required this.canInitiate,
    this.conversation,
  }) : super._();
  @override
  DirectConversationLookupResponseDto rebuild(
    void Function(DirectConversationLookupResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationLookupResponseDtoBuilder toBuilder() =>
      DirectConversationLookupResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationLookupResponseDto &&
        contactState == other.contactState &&
        canInitiate == other.canInitiate &&
        conversation == other.conversation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contactState.hashCode);
    _$hash = $jc(_$hash, canInitiate.hashCode);
    _$hash = $jc(_$hash, conversation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DirectConversationLookupResponseDto')
          ..add('contactState', contactState)
          ..add('canInitiate', canInitiate)
          ..add('conversation', conversation))
        .toString();
  }
}

class DirectConversationLookupResponseDtoBuilder
    implements
        Builder<
          DirectConversationLookupResponseDto,
          DirectConversationLookupResponseDtoBuilder
        > {
  _$DirectConversationLookupResponseDto? _$v;

  DirectConversationLookupResponseDtoContactStateEnum? _contactState;
  DirectConversationLookupResponseDtoContactStateEnum? get contactState =>
      _$this._contactState;
  set contactState(
    DirectConversationLookupResponseDtoContactStateEnum? contactState,
  ) => _$this._contactState = contactState;

  bool? _canInitiate;
  bool? get canInitiate => _$this._canInitiate;
  set canInitiate(bool? canInitiate) => _$this._canInitiate = canInitiate;

  DirectConversationResponseDtoBuilder? _conversation;
  DirectConversationResponseDtoBuilder get conversation =>
      _$this._conversation ??= DirectConversationResponseDtoBuilder();
  set conversation(DirectConversationResponseDtoBuilder? conversation) =>
      _$this._conversation = conversation;

  DirectConversationLookupResponseDtoBuilder() {
    DirectConversationLookupResponseDto._defaults(this);
  }

  DirectConversationLookupResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contactState = $v.contactState;
      _canInitiate = $v.canInitiate;
      _conversation = $v.conversation?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectConversationLookupResponseDto other) {
    _$v = other as _$DirectConversationLookupResponseDto;
  }

  @override
  void update(
    void Function(DirectConversationLookupResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationLookupResponseDto build() => _build();

  _$DirectConversationLookupResponseDto _build() {
    _$DirectConversationLookupResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationLookupResponseDto._(
            contactState: BuiltValueNullFieldError.checkNotNull(
              contactState,
              r'DirectConversationLookupResponseDto',
              'contactState',
            ),
            canInitiate: BuiltValueNullFieldError.checkNotNull(
              canInitiate,
              r'DirectConversationLookupResponseDto',
              'canInitiate',
            ),
            conversation: _conversation?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'conversation';
        _conversation?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DirectConversationLookupResponseDto',
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
