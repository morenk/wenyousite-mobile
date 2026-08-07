// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversation_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationResponseDtoStatusEnum
_$directConversationResponseDtoStatusEnum_PENDING =
    const DirectConversationResponseDtoStatusEnum._('PENDING');
const DirectConversationResponseDtoStatusEnum
_$directConversationResponseDtoStatusEnum_ACCEPTED =
    const DirectConversationResponseDtoStatusEnum._('ACCEPTED');
const DirectConversationResponseDtoStatusEnum
_$directConversationResponseDtoStatusEnum_DECLINED =
    const DirectConversationResponseDtoStatusEnum._('DECLINED');
const DirectConversationResponseDtoStatusEnum
_$directConversationResponseDtoStatusEnum_CANCELED =
    const DirectConversationResponseDtoStatusEnum._('CANCELED');
const DirectConversationResponseDtoStatusEnum
_$directConversationResponseDtoStatusEnum_unknownDefaultOpenApi =
    const DirectConversationResponseDtoStatusEnum._('unknownDefaultOpenApi');

DirectConversationResponseDtoStatusEnum
_$directConversationResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$directConversationResponseDtoStatusEnum_PENDING;
    case 'ACCEPTED':
      return _$directConversationResponseDtoStatusEnum_ACCEPTED;
    case 'DECLINED':
      return _$directConversationResponseDtoStatusEnum_DECLINED;
    case 'CANCELED':
      return _$directConversationResponseDtoStatusEnum_CANCELED;
    case 'unknownDefaultOpenApi':
      return _$directConversationResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationResponseDtoStatusEnum>
_$directConversationResponseDtoStatusEnumValues =
    BuiltSet<DirectConversationResponseDtoStatusEnum>(
      const <DirectConversationResponseDtoStatusEnum>[
        _$directConversationResponseDtoStatusEnum_PENDING,
        _$directConversationResponseDtoStatusEnum_ACCEPTED,
        _$directConversationResponseDtoStatusEnum_DECLINED,
        _$directConversationResponseDtoStatusEnum_CANCELED,
        _$directConversationResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

const DirectConversationResponseDtoRequestDirectionEnum
_$directConversationResponseDtoRequestDirectionEnum_NONE =
    const DirectConversationResponseDtoRequestDirectionEnum._('NONE');
const DirectConversationResponseDtoRequestDirectionEnum
_$directConversationResponseDtoRequestDirectionEnum_INCOMING =
    const DirectConversationResponseDtoRequestDirectionEnum._('INCOMING');
const DirectConversationResponseDtoRequestDirectionEnum
_$directConversationResponseDtoRequestDirectionEnum_OUTGOING =
    const DirectConversationResponseDtoRequestDirectionEnum._('OUTGOING');
const DirectConversationResponseDtoRequestDirectionEnum
_$directConversationResponseDtoRequestDirectionEnum_unknownDefaultOpenApi =
    const DirectConversationResponseDtoRequestDirectionEnum._(
      'unknownDefaultOpenApi',
    );

DirectConversationResponseDtoRequestDirectionEnum
_$directConversationResponseDtoRequestDirectionEnumValueOf(String name) {
  switch (name) {
    case 'NONE':
      return _$directConversationResponseDtoRequestDirectionEnum_NONE;
    case 'INCOMING':
      return _$directConversationResponseDtoRequestDirectionEnum_INCOMING;
    case 'OUTGOING':
      return _$directConversationResponseDtoRequestDirectionEnum_OUTGOING;
    case 'unknownDefaultOpenApi':
      return _$directConversationResponseDtoRequestDirectionEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationResponseDtoRequestDirectionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationResponseDtoRequestDirectionEnum>
_$directConversationResponseDtoRequestDirectionEnumValues =
    BuiltSet<DirectConversationResponseDtoRequestDirectionEnum>(const <
      DirectConversationResponseDtoRequestDirectionEnum
    >[
      _$directConversationResponseDtoRequestDirectionEnum_NONE,
      _$directConversationResponseDtoRequestDirectionEnum_INCOMING,
      _$directConversationResponseDtoRequestDirectionEnum_OUTGOING,
      _$directConversationResponseDtoRequestDirectionEnum_unknownDefaultOpenApi,
    ]);

Serializer<DirectConversationResponseDtoStatusEnum>
_$directConversationResponseDtoStatusEnumSerializer =
    _$DirectConversationResponseDtoStatusEnumSerializer();
Serializer<DirectConversationResponseDtoRequestDirectionEnum>
_$directConversationResponseDtoRequestDirectionEnumSerializer =
    _$DirectConversationResponseDtoRequestDirectionEnumSerializer();

class _$DirectConversationResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<DirectConversationResponseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PENDING': 'PENDING',
    'ACCEPTED': 'ACCEPTED',
    'DECLINED': 'DECLINED',
    'CANCELED': 'CANCELED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PENDING': 'PENDING',
    'ACCEPTED': 'ACCEPTED',
    'DECLINED': 'DECLINED',
    'CANCELED': 'CANCELED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    DirectConversationResponseDtoStatusEnum,
  ];
  @override
  final String wireName = 'DirectConversationResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationResponseDtoRequestDirectionEnumSerializer
    implements
        PrimitiveSerializer<DirectConversationResponseDtoRequestDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'NONE': 'NONE',
    'INCOMING': 'INCOMING',
    'OUTGOING': 'OUTGOING',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'NONE': 'NONE',
    'INCOMING': 'INCOMING',
    'OUTGOING': 'OUTGOING',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    DirectConversationResponseDtoRequestDirectionEnum,
  ];
  @override
  final String wireName = 'DirectConversationResponseDtoRequestDirectionEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationResponseDtoRequestDirectionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationResponseDtoRequestDirectionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationResponseDtoRequestDirectionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationResponseDto extends DirectConversationResponseDto {
  @override
  final String id;
  @override
  final DirectConversationResponseDtoStatusEnum status;
  @override
  final DirectConversationResponseDtoRequestDirectionEnum requestDirection;
  @override
  final DirectMessageUserResponseDto otherUser;
  @override
  final DirectMessagePreviewResponseDto? lastMessage;
  @override
  final num unreadCount;
  @override
  final DateTime? archivedAt;
  @override
  final DateTime? lastMessageAt;
  @override
  final DateTime createdAt;
  @override
  final bool canSend;
  @override
  final bool canAccept;
  @override
  final bool canDecline;
  @override
  final bool isBlocked;

  factory _$DirectConversationResponseDto([
    void Function(DirectConversationResponseDtoBuilder)? updates,
  ]) => (DirectConversationResponseDtoBuilder()..update(updates))._build();

  _$DirectConversationResponseDto._({
    required this.id,
    required this.status,
    required this.requestDirection,
    required this.otherUser,
    this.lastMessage,
    required this.unreadCount,
    this.archivedAt,
    this.lastMessageAt,
    required this.createdAt,
    required this.canSend,
    required this.canAccept,
    required this.canDecline,
    required this.isBlocked,
  }) : super._();
  @override
  DirectConversationResponseDto rebuild(
    void Function(DirectConversationResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationResponseDtoBuilder toBuilder() =>
      DirectConversationResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationResponseDto &&
        id == other.id &&
        status == other.status &&
        requestDirection == other.requestDirection &&
        otherUser == other.otherUser &&
        lastMessage == other.lastMessage &&
        unreadCount == other.unreadCount &&
        archivedAt == other.archivedAt &&
        lastMessageAt == other.lastMessageAt &&
        createdAt == other.createdAt &&
        canSend == other.canSend &&
        canAccept == other.canAccept &&
        canDecline == other.canDecline &&
        isBlocked == other.isBlocked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, requestDirection.hashCode);
    _$hash = $jc(_$hash, otherUser.hashCode);
    _$hash = $jc(_$hash, lastMessage.hashCode);
    _$hash = $jc(_$hash, unreadCount.hashCode);
    _$hash = $jc(_$hash, archivedAt.hashCode);
    _$hash = $jc(_$hash, lastMessageAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, canSend.hashCode);
    _$hash = $jc(_$hash, canAccept.hashCode);
    _$hash = $jc(_$hash, canDecline.hashCode);
    _$hash = $jc(_$hash, isBlocked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DirectConversationResponseDto')
          ..add('id', id)
          ..add('status', status)
          ..add('requestDirection', requestDirection)
          ..add('otherUser', otherUser)
          ..add('lastMessage', lastMessage)
          ..add('unreadCount', unreadCount)
          ..add('archivedAt', archivedAt)
          ..add('lastMessageAt', lastMessageAt)
          ..add('createdAt', createdAt)
          ..add('canSend', canSend)
          ..add('canAccept', canAccept)
          ..add('canDecline', canDecline)
          ..add('isBlocked', isBlocked))
        .toString();
  }
}

class DirectConversationResponseDtoBuilder
    implements
        Builder<
          DirectConversationResponseDto,
          DirectConversationResponseDtoBuilder
        > {
  _$DirectConversationResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DirectConversationResponseDtoStatusEnum? _status;
  DirectConversationResponseDtoStatusEnum? get status => _$this._status;
  set status(DirectConversationResponseDtoStatusEnum? status) =>
      _$this._status = status;

  DirectConversationResponseDtoRequestDirectionEnum? _requestDirection;
  DirectConversationResponseDtoRequestDirectionEnum? get requestDirection =>
      _$this._requestDirection;
  set requestDirection(
    DirectConversationResponseDtoRequestDirectionEnum? requestDirection,
  ) => _$this._requestDirection = requestDirection;

  DirectMessageUserResponseDtoBuilder? _otherUser;
  DirectMessageUserResponseDtoBuilder get otherUser =>
      _$this._otherUser ??= DirectMessageUserResponseDtoBuilder();
  set otherUser(DirectMessageUserResponseDtoBuilder? otherUser) =>
      _$this._otherUser = otherUser;

  DirectMessagePreviewResponseDtoBuilder? _lastMessage;
  DirectMessagePreviewResponseDtoBuilder get lastMessage =>
      _$this._lastMessage ??= DirectMessagePreviewResponseDtoBuilder();
  set lastMessage(DirectMessagePreviewResponseDtoBuilder? lastMessage) =>
      _$this._lastMessage = lastMessage;

  num? _unreadCount;
  num? get unreadCount => _$this._unreadCount;
  set unreadCount(num? unreadCount) => _$this._unreadCount = unreadCount;

  DateTime? _archivedAt;
  DateTime? get archivedAt => _$this._archivedAt;
  set archivedAt(DateTime? archivedAt) => _$this._archivedAt = archivedAt;

  DateTime? _lastMessageAt;
  DateTime? get lastMessageAt => _$this._lastMessageAt;
  set lastMessageAt(DateTime? lastMessageAt) =>
      _$this._lastMessageAt = lastMessageAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  bool? _canSend;
  bool? get canSend => _$this._canSend;
  set canSend(bool? canSend) => _$this._canSend = canSend;

  bool? _canAccept;
  bool? get canAccept => _$this._canAccept;
  set canAccept(bool? canAccept) => _$this._canAccept = canAccept;

  bool? _canDecline;
  bool? get canDecline => _$this._canDecline;
  set canDecline(bool? canDecline) => _$this._canDecline = canDecline;

  bool? _isBlocked;
  bool? get isBlocked => _$this._isBlocked;
  set isBlocked(bool? isBlocked) => _$this._isBlocked = isBlocked;

  DirectConversationResponseDtoBuilder() {
    DirectConversationResponseDto._defaults(this);
  }

  DirectConversationResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _requestDirection = $v.requestDirection;
      _otherUser = $v.otherUser.toBuilder();
      _lastMessage = $v.lastMessage?.toBuilder();
      _unreadCount = $v.unreadCount;
      _archivedAt = $v.archivedAt;
      _lastMessageAt = $v.lastMessageAt;
      _createdAt = $v.createdAt;
      _canSend = $v.canSend;
      _canAccept = $v.canAccept;
      _canDecline = $v.canDecline;
      _isBlocked = $v.isBlocked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectConversationResponseDto other) {
    _$v = other as _$DirectConversationResponseDto;
  }

  @override
  void update(void Function(DirectConversationResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationResponseDto build() => _build();

  _$DirectConversationResponseDto _build() {
    _$DirectConversationResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'DirectConversationResponseDto',
              'id',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'DirectConversationResponseDto',
              'status',
            ),
            requestDirection: BuiltValueNullFieldError.checkNotNull(
              requestDirection,
              r'DirectConversationResponseDto',
              'requestDirection',
            ),
            otherUser: otherUser.build(),
            lastMessage: _lastMessage?.build(),
            unreadCount: BuiltValueNullFieldError.checkNotNull(
              unreadCount,
              r'DirectConversationResponseDto',
              'unreadCount',
            ),
            archivedAt: archivedAt,
            lastMessageAt: lastMessageAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'DirectConversationResponseDto',
              'createdAt',
            ),
            canSend: BuiltValueNullFieldError.checkNotNull(
              canSend,
              r'DirectConversationResponseDto',
              'canSend',
            ),
            canAccept: BuiltValueNullFieldError.checkNotNull(
              canAccept,
              r'DirectConversationResponseDto',
              'canAccept',
            ),
            canDecline: BuiltValueNullFieldError.checkNotNull(
              canDecline,
              r'DirectConversationResponseDto',
              'canDecline',
            ),
            isBlocked: BuiltValueNullFieldError.checkNotNull(
              isBlocked,
              r'DirectConversationResponseDto',
              'isBlocked',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'otherUser';
        otherUser.build();
        _$failedField = 'lastMessage';
        _lastMessage?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DirectConversationResponseDto',
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
