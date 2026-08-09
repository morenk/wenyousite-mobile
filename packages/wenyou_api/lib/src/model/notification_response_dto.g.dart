// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationResponseDtoTypeEnum _$notificationResponseDtoTypeEnum_reply =
    const NotificationResponseDtoTypeEnum._('reply');
const NotificationResponseDtoTypeEnum
_$notificationResponseDtoTypeEnum_mention =
    const NotificationResponseDtoTypeEnum._('mention');
const NotificationResponseDtoTypeEnum
_$notificationResponseDtoTypeEnum_newFloor =
    const NotificationResponseDtoTypeEnum._('newFloor');
const NotificationResponseDtoTypeEnum
_$notificationResponseDtoTypeEnum_subthreadCreated =
    const NotificationResponseDtoTypeEnum._('subthreadCreated');
const NotificationResponseDtoTypeEnum
_$notificationResponseDtoTypeEnum_newPost =
    const NotificationResponseDtoTypeEnum._('newPost');
const NotificationResponseDtoTypeEnum
_$notificationResponseDtoTypeEnum_threadCreated =
    const NotificationResponseDtoTypeEnum._('threadCreated');
const NotificationResponseDtoTypeEnum _$notificationResponseDtoTypeEnum_follow =
    const NotificationResponseDtoTypeEnum._('follow');
const NotificationResponseDtoTypeEnum _$notificationResponseDtoTypeEnum_like =
    const NotificationResponseDtoTypeEnum._('like');
const NotificationResponseDtoTypeEnum _$notificationResponseDtoTypeEnum_tip =
    const NotificationResponseDtoTypeEnum._('tip');
const NotificationResponseDtoTypeEnum
_$notificationResponseDtoTypeEnum_levelUp =
    const NotificationResponseDtoTypeEnum._('levelUp');
const NotificationResponseDtoTypeEnum _$notificationResponseDtoTypeEnum_system =
    const NotificationResponseDtoTypeEnum._('system');
const NotificationResponseDtoTypeEnum
_$notificationResponseDtoTypeEnum_unknownDefaultOpenApi =
    const NotificationResponseDtoTypeEnum._('unknownDefaultOpenApi');

NotificationResponseDtoTypeEnum _$notificationResponseDtoTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'reply':
      return _$notificationResponseDtoTypeEnum_reply;
    case 'mention':
      return _$notificationResponseDtoTypeEnum_mention;
    case 'newFloor':
      return _$notificationResponseDtoTypeEnum_newFloor;
    case 'subthreadCreated':
      return _$notificationResponseDtoTypeEnum_subthreadCreated;
    case 'newPost':
      return _$notificationResponseDtoTypeEnum_newPost;
    case 'threadCreated':
      return _$notificationResponseDtoTypeEnum_threadCreated;
    case 'follow':
      return _$notificationResponseDtoTypeEnum_follow;
    case 'like':
      return _$notificationResponseDtoTypeEnum_like;
    case 'tip':
      return _$notificationResponseDtoTypeEnum_tip;
    case 'levelUp':
      return _$notificationResponseDtoTypeEnum_levelUp;
    case 'system':
      return _$notificationResponseDtoTypeEnum_system;
    case 'unknownDefaultOpenApi':
      return _$notificationResponseDtoTypeEnum_unknownDefaultOpenApi;
    default:
      return _$notificationResponseDtoTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationResponseDtoTypeEnum>
_$notificationResponseDtoTypeEnumValues =
    BuiltSet<NotificationResponseDtoTypeEnum>(
      const <NotificationResponseDtoTypeEnum>[
        _$notificationResponseDtoTypeEnum_reply,
        _$notificationResponseDtoTypeEnum_mention,
        _$notificationResponseDtoTypeEnum_newFloor,
        _$notificationResponseDtoTypeEnum_subthreadCreated,
        _$notificationResponseDtoTypeEnum_newPost,
        _$notificationResponseDtoTypeEnum_threadCreated,
        _$notificationResponseDtoTypeEnum_follow,
        _$notificationResponseDtoTypeEnum_like,
        _$notificationResponseDtoTypeEnum_tip,
        _$notificationResponseDtoTypeEnum_levelUp,
        _$notificationResponseDtoTypeEnum_system,
        _$notificationResponseDtoTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationResponseDtoTypeEnum>
_$notificationResponseDtoTypeEnumSerializer =
    _$NotificationResponseDtoTypeEnumSerializer();

class _$NotificationResponseDtoTypeEnumSerializer
    implements PrimitiveSerializer<NotificationResponseDtoTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'reply': 'reply',
    'mention': 'mention',
    'newFloor': 'new_floor',
    'subthreadCreated': 'subthread_created',
    'newPost': 'new_post',
    'threadCreated': 'thread_created',
    'follow': 'follow',
    'like': 'like',
    'tip': 'tip',
    'levelUp': 'level_up',
    'system': 'system',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'reply': 'reply',
    'mention': 'mention',
    'new_floor': 'newFloor',
    'subthread_created': 'subthreadCreated',
    'new_post': 'newPost',
    'thread_created': 'threadCreated',
    'follow': 'follow',
    'like': 'like',
    'tip': 'tip',
    'level_up': 'levelUp',
    'system': 'system',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[NotificationResponseDtoTypeEnum];
  @override
  final String wireName = 'NotificationResponseDtoTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationResponseDtoTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationResponseDtoTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationResponseDtoTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationResponseDto extends NotificationResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final NotificationResponseDtoTypeEnum type;
  @override
  final String? content;
  @override
  final NotificationPayloadResponseDto? payload;
  @override
  final NotificationTargetResponseDto target;
  @override
  final String? postId;
  @override
  final String? threadId;
  @override
  final String? momentId;
  @override
  final String? momentCommentId;
  @override
  final String? fromUserId;
  @override
  final String eventKey;
  @override
  final bool isRead;
  @override
  final DateTime createdAt;
  @override
  final NotificationPostResponseDto? post;
  @override
  final NotificationThreadResponseDto? thread;
  @override
  final NotificationMomentResponseDto? moment;
  @override
  final NotificationMomentCommentResponseDto? momentComment;
  @override
  final NotificationFromUserResponseDto? fromUser;

  factory _$NotificationResponseDto([
    void Function(NotificationResponseDtoBuilder)? updates,
  ]) => (NotificationResponseDtoBuilder()..update(updates))._build();

  _$NotificationResponseDto._({
    required this.id,
    required this.userId,
    required this.type,
    this.content,
    this.payload,
    required this.target,
    this.postId,
    this.threadId,
    this.momentId,
    this.momentCommentId,
    this.fromUserId,
    required this.eventKey,
    required this.isRead,
    required this.createdAt,
    this.post,
    this.thread,
    this.moment,
    this.momentComment,
    this.fromUser,
  }) : super._();
  @override
  NotificationResponseDto rebuild(
    void Function(NotificationResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationResponseDtoBuilder toBuilder() =>
      NotificationResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationResponseDto &&
        id == other.id &&
        userId == other.userId &&
        type == other.type &&
        content == other.content &&
        payload == other.payload &&
        target == other.target &&
        postId == other.postId &&
        threadId == other.threadId &&
        momentId == other.momentId &&
        momentCommentId == other.momentCommentId &&
        fromUserId == other.fromUserId &&
        eventKey == other.eventKey &&
        isRead == other.isRead &&
        createdAt == other.createdAt &&
        post == other.post &&
        thread == other.thread &&
        moment == other.moment &&
        momentComment == other.momentComment &&
        fromUser == other.fromUser;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, postId.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, momentId.hashCode);
    _$hash = $jc(_$hash, momentCommentId.hashCode);
    _$hash = $jc(_$hash, fromUserId.hashCode);
    _$hash = $jc(_$hash, eventKey.hashCode);
    _$hash = $jc(_$hash, isRead.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, post.hashCode);
    _$hash = $jc(_$hash, thread.hashCode);
    _$hash = $jc(_$hash, moment.hashCode);
    _$hash = $jc(_$hash, momentComment.hashCode);
    _$hash = $jc(_$hash, fromUser.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('type', type)
          ..add('content', content)
          ..add('payload', payload)
          ..add('target', target)
          ..add('postId', postId)
          ..add('threadId', threadId)
          ..add('momentId', momentId)
          ..add('momentCommentId', momentCommentId)
          ..add('fromUserId', fromUserId)
          ..add('eventKey', eventKey)
          ..add('isRead', isRead)
          ..add('createdAt', createdAt)
          ..add('post', post)
          ..add('thread', thread)
          ..add('moment', moment)
          ..add('momentComment', momentComment)
          ..add('fromUser', fromUser))
        .toString();
  }
}

class NotificationResponseDtoBuilder
    implements
        Builder<NotificationResponseDto, NotificationResponseDtoBuilder> {
  _$NotificationResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  NotificationResponseDtoTypeEnum? _type;
  NotificationResponseDtoTypeEnum? get type => _$this._type;
  set type(NotificationResponseDtoTypeEnum? type) => _$this._type = type;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  NotificationPayloadResponseDtoBuilder? _payload;
  NotificationPayloadResponseDtoBuilder get payload =>
      _$this._payload ??= NotificationPayloadResponseDtoBuilder();
  set payload(NotificationPayloadResponseDtoBuilder? payload) =>
      _$this._payload = payload;

  NotificationTargetResponseDtoBuilder? _target;
  NotificationTargetResponseDtoBuilder get target =>
      _$this._target ??= NotificationTargetResponseDtoBuilder();
  set target(NotificationTargetResponseDtoBuilder? target) =>
      _$this._target = target;

  String? _postId;
  String? get postId => _$this._postId;
  set postId(String? postId) => _$this._postId = postId;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _momentId;
  String? get momentId => _$this._momentId;
  set momentId(String? momentId) => _$this._momentId = momentId;

  String? _momentCommentId;
  String? get momentCommentId => _$this._momentCommentId;
  set momentCommentId(String? momentCommentId) =>
      _$this._momentCommentId = momentCommentId;

  String? _fromUserId;
  String? get fromUserId => _$this._fromUserId;
  set fromUserId(String? fromUserId) => _$this._fromUserId = fromUserId;

  String? _eventKey;
  String? get eventKey => _$this._eventKey;
  set eventKey(String? eventKey) => _$this._eventKey = eventKey;

  bool? _isRead;
  bool? get isRead => _$this._isRead;
  set isRead(bool? isRead) => _$this._isRead = isRead;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  NotificationPostResponseDtoBuilder? _post;
  NotificationPostResponseDtoBuilder get post =>
      _$this._post ??= NotificationPostResponseDtoBuilder();
  set post(NotificationPostResponseDtoBuilder? post) => _$this._post = post;

  NotificationThreadResponseDtoBuilder? _thread;
  NotificationThreadResponseDtoBuilder get thread =>
      _$this._thread ??= NotificationThreadResponseDtoBuilder();
  set thread(NotificationThreadResponseDtoBuilder? thread) =>
      _$this._thread = thread;

  NotificationMomentResponseDtoBuilder? _moment;
  NotificationMomentResponseDtoBuilder get moment =>
      _$this._moment ??= NotificationMomentResponseDtoBuilder();
  set moment(NotificationMomentResponseDtoBuilder? moment) =>
      _$this._moment = moment;

  NotificationMomentCommentResponseDtoBuilder? _momentComment;
  NotificationMomentCommentResponseDtoBuilder get momentComment =>
      _$this._momentComment ??= NotificationMomentCommentResponseDtoBuilder();
  set momentComment(
    NotificationMomentCommentResponseDtoBuilder? momentComment,
  ) => _$this._momentComment = momentComment;

  NotificationFromUserResponseDtoBuilder? _fromUser;
  NotificationFromUserResponseDtoBuilder get fromUser =>
      _$this._fromUser ??= NotificationFromUserResponseDtoBuilder();
  set fromUser(NotificationFromUserResponseDtoBuilder? fromUser) =>
      _$this._fromUser = fromUser;

  NotificationResponseDtoBuilder() {
    NotificationResponseDto._defaults(this);
  }

  NotificationResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _type = $v.type;
      _content = $v.content;
      _payload = $v.payload?.toBuilder();
      _target = $v.target.toBuilder();
      _postId = $v.postId;
      _threadId = $v.threadId;
      _momentId = $v.momentId;
      _momentCommentId = $v.momentCommentId;
      _fromUserId = $v.fromUserId;
      _eventKey = $v.eventKey;
      _isRead = $v.isRead;
      _createdAt = $v.createdAt;
      _post = $v.post?.toBuilder();
      _thread = $v.thread?.toBuilder();
      _moment = $v.moment?.toBuilder();
      _momentComment = $v.momentComment?.toBuilder();
      _fromUser = $v.fromUser?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationResponseDto other) {
    _$v = other as _$NotificationResponseDto;
  }

  @override
  void update(void Function(NotificationResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationResponseDto build() => _build();

  _$NotificationResponseDto _build() {
    _$NotificationResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$NotificationResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'NotificationResponseDto',
              'id',
            ),
            userId: BuiltValueNullFieldError.checkNotNull(
              userId,
              r'NotificationResponseDto',
              'userId',
            ),
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'NotificationResponseDto',
              'type',
            ),
            content: content,
            payload: _payload?.build(),
            target: target.build(),
            postId: postId,
            threadId: threadId,
            momentId: momentId,
            momentCommentId: momentCommentId,
            fromUserId: fromUserId,
            eventKey: BuiltValueNullFieldError.checkNotNull(
              eventKey,
              r'NotificationResponseDto',
              'eventKey',
            ),
            isRead: BuiltValueNullFieldError.checkNotNull(
              isRead,
              r'NotificationResponseDto',
              'isRead',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'NotificationResponseDto',
              'createdAt',
            ),
            post: _post?.build(),
            thread: _thread?.build(),
            moment: _moment?.build(),
            momentComment: _momentComment?.build(),
            fromUser: _fromUser?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        _payload?.build();
        _$failedField = 'target';
        target.build();

        _$failedField = 'post';
        _post?.build();
        _$failedField = 'thread';
        _thread?.build();
        _$failedField = 'moment';
        _moment?.build();
        _$failedField = 'momentComment';
        _momentComment?.build();
        _$failedField = 'fromUser';
        _fromUser?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'NotificationResponseDto',
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
