// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_subthread_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadSubthreadCountResponseDto
    extends ThreadSubthreadCountResponseDto {
  @override
  final num posts;

  factory _$ThreadSubthreadCountResponseDto([
    void Function(ThreadSubthreadCountResponseDtoBuilder)? updates,
  ]) => (ThreadSubthreadCountResponseDtoBuilder()..update(updates))._build();

  _$ThreadSubthreadCountResponseDto._({required this.posts}) : super._();
  @override
  ThreadSubthreadCountResponseDto rebuild(
    void Function(ThreadSubthreadCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadSubthreadCountResponseDtoBuilder toBuilder() =>
      ThreadSubthreadCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadSubthreadCountResponseDto && posts == other.posts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, posts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'ThreadSubthreadCountResponseDto',
    )..add('posts', posts)).toString();
  }
}

class ThreadSubthreadCountResponseDtoBuilder
    implements
        Builder<
          ThreadSubthreadCountResponseDto,
          ThreadSubthreadCountResponseDtoBuilder
        > {
  _$ThreadSubthreadCountResponseDto? _$v;

  num? _posts;
  num? get posts => _$this._posts;
  set posts(num? posts) => _$this._posts = posts;

  ThreadSubthreadCountResponseDtoBuilder() {
    ThreadSubthreadCountResponseDto._defaults(this);
  }

  ThreadSubthreadCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _posts = $v.posts;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadSubthreadCountResponseDto other) {
    _$v = other as _$ThreadSubthreadCountResponseDto;
  }

  @override
  void update(void Function(ThreadSubthreadCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadSubthreadCountResponseDto build() => _build();

  _$ThreadSubthreadCountResponseDto _build() {
    final _$result =
        _$v ??
        _$ThreadSubthreadCountResponseDto._(
          posts: BuiltValueNullFieldError.checkNotNull(
            posts,
            r'ThreadSubthreadCountResponseDto',
            'posts',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
