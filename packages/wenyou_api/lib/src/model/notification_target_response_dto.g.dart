// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_target_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationTargetResponseDtoKindEnum
_$notificationTargetResponseDtoKindEnum_post =
    const NotificationTargetResponseDtoKindEnum._('post');
const NotificationTargetResponseDtoKindEnum
_$notificationTargetResponseDtoKindEnum_thread =
    const NotificationTargetResponseDtoKindEnum._('thread');
const NotificationTargetResponseDtoKindEnum
_$notificationTargetResponseDtoKindEnum_moment =
    const NotificationTargetResponseDtoKindEnum._('moment');
const NotificationTargetResponseDtoKindEnum
_$notificationTargetResponseDtoKindEnum_user =
    const NotificationTargetResponseDtoKindEnum._('user');
const NotificationTargetResponseDtoKindEnum
_$notificationTargetResponseDtoKindEnum_none =
    const NotificationTargetResponseDtoKindEnum._('none');
const NotificationTargetResponseDtoKindEnum
_$notificationTargetResponseDtoKindEnum_unknownDefaultOpenApi =
    const NotificationTargetResponseDtoKindEnum._('unknownDefaultOpenApi');

NotificationTargetResponseDtoKindEnum
_$notificationTargetResponseDtoKindEnumValueOf(String name) {
  switch (name) {
    case 'post':
      return _$notificationTargetResponseDtoKindEnum_post;
    case 'thread':
      return _$notificationTargetResponseDtoKindEnum_thread;
    case 'moment':
      return _$notificationTargetResponseDtoKindEnum_moment;
    case 'user':
      return _$notificationTargetResponseDtoKindEnum_user;
    case 'none':
      return _$notificationTargetResponseDtoKindEnum_none;
    case 'unknownDefaultOpenApi':
      return _$notificationTargetResponseDtoKindEnum_unknownDefaultOpenApi;
    default:
      return _$notificationTargetResponseDtoKindEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationTargetResponseDtoKindEnum>
_$notificationTargetResponseDtoKindEnumValues =
    BuiltSet<NotificationTargetResponseDtoKindEnum>(
      const <NotificationTargetResponseDtoKindEnum>[
        _$notificationTargetResponseDtoKindEnum_post,
        _$notificationTargetResponseDtoKindEnum_thread,
        _$notificationTargetResponseDtoKindEnum_moment,
        _$notificationTargetResponseDtoKindEnum_user,
        _$notificationTargetResponseDtoKindEnum_none,
        _$notificationTargetResponseDtoKindEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationTargetResponseDtoKindEnum>
_$notificationTargetResponseDtoKindEnumSerializer =
    _$NotificationTargetResponseDtoKindEnumSerializer();

class _$NotificationTargetResponseDtoKindEnumSerializer
    implements PrimitiveSerializer<NotificationTargetResponseDtoKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'post': 'post',
    'thread': 'thread',
    'moment': 'moment',
    'user': 'user',
    'none': 'none',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'post': 'post',
    'thread': 'thread',
    'moment': 'moment',
    'user': 'user',
    'none': 'none',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    NotificationTargetResponseDtoKindEnum,
  ];
  @override
  final String wireName = 'NotificationTargetResponseDtoKindEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationTargetResponseDtoKindEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationTargetResponseDtoKindEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationTargetResponseDtoKindEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationTargetResponseDto extends NotificationTargetResponseDto {
  @override
  final NotificationTargetResponseDtoKindEnum kind;
  @override
  final String? threadId;
  @override
  final String? postId;
  @override
  final String? momentId;
  @override
  final String? momentCommentId;
  @override
  final String? userId;

  factory _$NotificationTargetResponseDto([
    void Function(NotificationTargetResponseDtoBuilder)? updates,
  ]) => (NotificationTargetResponseDtoBuilder()..update(updates))._build();

  _$NotificationTargetResponseDto._({
    required this.kind,
    this.threadId,
    this.postId,
    this.momentId,
    this.momentCommentId,
    this.userId,
  }) : super._();
  @override
  NotificationTargetResponseDto rebuild(
    void Function(NotificationTargetResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationTargetResponseDtoBuilder toBuilder() =>
      NotificationTargetResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationTargetResponseDto &&
        kind == other.kind &&
        threadId == other.threadId &&
        postId == other.postId &&
        momentId == other.momentId &&
        momentCommentId == other.momentCommentId &&
        userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, postId.hashCode);
    _$hash = $jc(_$hash, momentId.hashCode);
    _$hash = $jc(_$hash, momentCommentId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationTargetResponseDto')
          ..add('kind', kind)
          ..add('threadId', threadId)
          ..add('postId', postId)
          ..add('momentId', momentId)
          ..add('momentCommentId', momentCommentId)
          ..add('userId', userId))
        .toString();
  }
}

class NotificationTargetResponseDtoBuilder
    implements
        Builder<
          NotificationTargetResponseDto,
          NotificationTargetResponseDtoBuilder
        > {
  _$NotificationTargetResponseDto? _$v;

  NotificationTargetResponseDtoKindEnum? _kind;
  NotificationTargetResponseDtoKindEnum? get kind => _$this._kind;
  set kind(NotificationTargetResponseDtoKindEnum? kind) => _$this._kind = kind;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _postId;
  String? get postId => _$this._postId;
  set postId(String? postId) => _$this._postId = postId;

  String? _momentId;
  String? get momentId => _$this._momentId;
  set momentId(String? momentId) => _$this._momentId = momentId;

  String? _momentCommentId;
  String? get momentCommentId => _$this._momentCommentId;
  set momentCommentId(String? momentCommentId) =>
      _$this._momentCommentId = momentCommentId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  NotificationTargetResponseDtoBuilder() {
    NotificationTargetResponseDto._defaults(this);
  }

  NotificationTargetResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _threadId = $v.threadId;
      _postId = $v.postId;
      _momentId = $v.momentId;
      _momentCommentId = $v.momentCommentId;
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationTargetResponseDto other) {
    _$v = other as _$NotificationTargetResponseDto;
  }

  @override
  void update(void Function(NotificationTargetResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationTargetResponseDto build() => _build();

  _$NotificationTargetResponseDto _build() {
    final _$result =
        _$v ??
        _$NotificationTargetResponseDto._(
          kind: BuiltValueNullFieldError.checkNotNull(
            kind,
            r'NotificationTargetResponseDto',
            'kind',
          ),
          threadId: threadId,
          postId: postId,
          momentId: momentId,
          momentCommentId: momentCommentId,
          userId: userId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
