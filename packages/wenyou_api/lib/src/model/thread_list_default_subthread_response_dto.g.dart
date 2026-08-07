// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_list_default_subthread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadListDefaultSubthreadResponseDto
    extends ThreadListDefaultSubthreadResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final DateTime? lastPostAt;

  factory _$ThreadListDefaultSubthreadResponseDto([
    void Function(ThreadListDefaultSubthreadResponseDtoBuilder)? updates,
  ]) => (ThreadListDefaultSubthreadResponseDtoBuilder()..update(updates))
      ._build();

  _$ThreadListDefaultSubthreadResponseDto._({
    required this.id,
    required this.title,
    this.lastPostAt,
  }) : super._();
  @override
  ThreadListDefaultSubthreadResponseDto rebuild(
    void Function(ThreadListDefaultSubthreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadListDefaultSubthreadResponseDtoBuilder toBuilder() =>
      ThreadListDefaultSubthreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadListDefaultSubthreadResponseDto &&
        id == other.id &&
        title == other.title &&
        lastPostAt == other.lastPostAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, lastPostAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ThreadListDefaultSubthreadResponseDto',
          )
          ..add('id', id)
          ..add('title', title)
          ..add('lastPostAt', lastPostAt))
        .toString();
  }
}

class ThreadListDefaultSubthreadResponseDtoBuilder
    implements
        Builder<
          ThreadListDefaultSubthreadResponseDto,
          ThreadListDefaultSubthreadResponseDtoBuilder
        > {
  _$ThreadListDefaultSubthreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  DateTime? _lastPostAt;
  DateTime? get lastPostAt => _$this._lastPostAt;
  set lastPostAt(DateTime? lastPostAt) => _$this._lastPostAt = lastPostAt;

  ThreadListDefaultSubthreadResponseDtoBuilder() {
    ThreadListDefaultSubthreadResponseDto._defaults(this);
  }

  ThreadListDefaultSubthreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _lastPostAt = $v.lastPostAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadListDefaultSubthreadResponseDto other) {
    _$v = other as _$ThreadListDefaultSubthreadResponseDto;
  }

  @override
  void update(
    void Function(ThreadListDefaultSubthreadResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadListDefaultSubthreadResponseDto build() => _build();

  _$ThreadListDefaultSubthreadResponseDto _build() {
    final _$result =
        _$v ??
        _$ThreadListDefaultSubthreadResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ThreadListDefaultSubthreadResponseDto',
            'id',
          ),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'ThreadListDefaultSubthreadResponseDto',
            'title',
          ),
          lastPostAt: lastPostAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
