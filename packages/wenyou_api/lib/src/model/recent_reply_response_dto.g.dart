// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_reply_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecentReplyResponseDto extends RecentReplyResponseDto {
  @override
  final String id;
  @override
  final DateTime createdAt;
  @override
  final num? floorNumber;
  @override
  final String? parentPostId;
  @override
  final String content;
  @override
  final String threadId;
  @override
  final RecentReplyThreadResponseDto thread;
  @override
  final String subthreadId;
  @override
  final RecentReplySubthreadResponseDto subthread;
  @override
  final BuiltList<RecentReplyDiceResponseDto> diceRolls;
  @override
  final String preview;

  factory _$RecentReplyResponseDto([
    void Function(RecentReplyResponseDtoBuilder)? updates,
  ]) => (RecentReplyResponseDtoBuilder()..update(updates))._build();

  _$RecentReplyResponseDto._({
    required this.id,
    required this.createdAt,
    this.floorNumber,
    this.parentPostId,
    required this.content,
    required this.threadId,
    required this.thread,
    required this.subthreadId,
    required this.subthread,
    required this.diceRolls,
    required this.preview,
  }) : super._();
  @override
  RecentReplyResponseDto rebuild(
    void Function(RecentReplyResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RecentReplyResponseDtoBuilder toBuilder() =>
      RecentReplyResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecentReplyResponseDto &&
        id == other.id &&
        createdAt == other.createdAt &&
        floorNumber == other.floorNumber &&
        parentPostId == other.parentPostId &&
        content == other.content &&
        threadId == other.threadId &&
        thread == other.thread &&
        subthreadId == other.subthreadId &&
        subthread == other.subthread &&
        diceRolls == other.diceRolls &&
        preview == other.preview;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, floorNumber.hashCode);
    _$hash = $jc(_$hash, parentPostId.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, thread.hashCode);
    _$hash = $jc(_$hash, subthreadId.hashCode);
    _$hash = $jc(_$hash, subthread.hashCode);
    _$hash = $jc(_$hash, diceRolls.hashCode);
    _$hash = $jc(_$hash, preview.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecentReplyResponseDto')
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('floorNumber', floorNumber)
          ..add('parentPostId', parentPostId)
          ..add('content', content)
          ..add('threadId', threadId)
          ..add('thread', thread)
          ..add('subthreadId', subthreadId)
          ..add('subthread', subthread)
          ..add('diceRolls', diceRolls)
          ..add('preview', preview))
        .toString();
  }
}

class RecentReplyResponseDtoBuilder
    implements Builder<RecentReplyResponseDto, RecentReplyResponseDtoBuilder> {
  _$RecentReplyResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  num? _floorNumber;
  num? get floorNumber => _$this._floorNumber;
  set floorNumber(num? floorNumber) => _$this._floorNumber = floorNumber;

  String? _parentPostId;
  String? get parentPostId => _$this._parentPostId;
  set parentPostId(String? parentPostId) => _$this._parentPostId = parentPostId;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  RecentReplyThreadResponseDtoBuilder? _thread;
  RecentReplyThreadResponseDtoBuilder get thread =>
      _$this._thread ??= RecentReplyThreadResponseDtoBuilder();
  set thread(RecentReplyThreadResponseDtoBuilder? thread) =>
      _$this._thread = thread;

  String? _subthreadId;
  String? get subthreadId => _$this._subthreadId;
  set subthreadId(String? subthreadId) => _$this._subthreadId = subthreadId;

  RecentReplySubthreadResponseDtoBuilder? _subthread;
  RecentReplySubthreadResponseDtoBuilder get subthread =>
      _$this._subthread ??= RecentReplySubthreadResponseDtoBuilder();
  set subthread(RecentReplySubthreadResponseDtoBuilder? subthread) =>
      _$this._subthread = subthread;

  ListBuilder<RecentReplyDiceResponseDto>? _diceRolls;
  ListBuilder<RecentReplyDiceResponseDto> get diceRolls =>
      _$this._diceRolls ??= ListBuilder<RecentReplyDiceResponseDto>();
  set diceRolls(ListBuilder<RecentReplyDiceResponseDto>? diceRolls) =>
      _$this._diceRolls = diceRolls;

  String? _preview;
  String? get preview => _$this._preview;
  set preview(String? preview) => _$this._preview = preview;

  RecentReplyResponseDtoBuilder() {
    RecentReplyResponseDto._defaults(this);
  }

  RecentReplyResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _createdAt = $v.createdAt;
      _floorNumber = $v.floorNumber;
      _parentPostId = $v.parentPostId;
      _content = $v.content;
      _threadId = $v.threadId;
      _thread = $v.thread.toBuilder();
      _subthreadId = $v.subthreadId;
      _subthread = $v.subthread.toBuilder();
      _diceRolls = $v.diceRolls.toBuilder();
      _preview = $v.preview;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecentReplyResponseDto other) {
    _$v = other as _$RecentReplyResponseDto;
  }

  @override
  void update(void Function(RecentReplyResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecentReplyResponseDto build() => _build();

  _$RecentReplyResponseDto _build() {
    _$RecentReplyResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$RecentReplyResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'RecentReplyResponseDto',
              'id',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'RecentReplyResponseDto',
              'createdAt',
            ),
            floorNumber: floorNumber,
            parentPostId: parentPostId,
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'RecentReplyResponseDto',
              'content',
            ),
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'RecentReplyResponseDto',
              'threadId',
            ),
            thread: thread.build(),
            subthreadId: BuiltValueNullFieldError.checkNotNull(
              subthreadId,
              r'RecentReplyResponseDto',
              'subthreadId',
            ),
            subthread: subthread.build(),
            diceRolls: diceRolls.build(),
            preview: BuiltValueNullFieldError.checkNotNull(
              preview,
              r'RecentReplyResponseDto',
              'preview',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'thread';
        thread.build();

        _$failedField = 'subthread';
        subthread.build();
        _$failedField = 'diceRolls';
        diceRolls.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'RecentReplyResponseDto',
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
