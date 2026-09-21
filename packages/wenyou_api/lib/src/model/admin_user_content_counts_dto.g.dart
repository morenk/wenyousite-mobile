// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_content_counts_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminUserContentCountsDto extends AdminUserContentCountsDto {
  @override
  final num thread;
  @override
  final num post;
  @override
  final num moment;
  @override
  final num momentComment;

  factory _$AdminUserContentCountsDto([
    void Function(AdminUserContentCountsDtoBuilder)? updates,
  ]) => (AdminUserContentCountsDtoBuilder()..update(updates))._build();

  _$AdminUserContentCountsDto._({
    required this.thread,
    required this.post,
    required this.moment,
    required this.momentComment,
  }) : super._();
  @override
  AdminUserContentCountsDto rebuild(
    void Function(AdminUserContentCountsDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminUserContentCountsDtoBuilder toBuilder() =>
      AdminUserContentCountsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUserContentCountsDto &&
        thread == other.thread &&
        post == other.post &&
        moment == other.moment &&
        momentComment == other.momentComment;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, thread.hashCode);
    _$hash = $jc(_$hash, post.hashCode);
    _$hash = $jc(_$hash, moment.hashCode);
    _$hash = $jc(_$hash, momentComment.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUserContentCountsDto')
          ..add('thread', thread)
          ..add('post', post)
          ..add('moment', moment)
          ..add('momentComment', momentComment))
        .toString();
  }
}

class AdminUserContentCountsDtoBuilder
    implements
        Builder<AdminUserContentCountsDto, AdminUserContentCountsDtoBuilder> {
  _$AdminUserContentCountsDto? _$v;

  num? _thread;
  num? get thread => _$this._thread;
  set thread(num? thread) => _$this._thread = thread;

  num? _post;
  num? get post => _$this._post;
  set post(num? post) => _$this._post = post;

  num? _moment;
  num? get moment => _$this._moment;
  set moment(num? moment) => _$this._moment = moment;

  num? _momentComment;
  num? get momentComment => _$this._momentComment;
  set momentComment(num? momentComment) =>
      _$this._momentComment = momentComment;

  AdminUserContentCountsDtoBuilder() {
    AdminUserContentCountsDto._defaults(this);
  }

  AdminUserContentCountsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _thread = $v.thread;
      _post = $v.post;
      _moment = $v.moment;
      _momentComment = $v.momentComment;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUserContentCountsDto other) {
    _$v = other as _$AdminUserContentCountsDto;
  }

  @override
  void update(void Function(AdminUserContentCountsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUserContentCountsDto build() => _build();

  _$AdminUserContentCountsDto _build() {
    final _$result =
        _$v ??
        _$AdminUserContentCountsDto._(
          thread: BuiltValueNullFieldError.checkNotNull(
            thread,
            r'AdminUserContentCountsDto',
            'thread',
          ),
          post: BuiltValueNullFieldError.checkNotNull(
            post,
            r'AdminUserContentCountsDto',
            'post',
          ),
          moment: BuiltValueNullFieldError.checkNotNull(
            moment,
            r'AdminUserContentCountsDto',
            'moment',
          ),
          momentComment: BuiltValueNullFieldError.checkNotNull(
            momentComment,
            r'AdminUserContentCountsDto',
            'momentComment',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
