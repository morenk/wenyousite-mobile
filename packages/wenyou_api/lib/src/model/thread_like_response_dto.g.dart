// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_like_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadLikeResponseDto extends ThreadLikeResponseDto {
  @override
  final String id;
  @override
  final num likeCount;

  factory _$ThreadLikeResponseDto([
    void Function(ThreadLikeResponseDtoBuilder)? updates,
  ]) => (ThreadLikeResponseDtoBuilder()..update(updates))._build();

  _$ThreadLikeResponseDto._({required this.id, required this.likeCount})
    : super._();
  @override
  ThreadLikeResponseDto rebuild(
    void Function(ThreadLikeResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadLikeResponseDtoBuilder toBuilder() =>
      ThreadLikeResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadLikeResponseDto &&
        id == other.id &&
        likeCount == other.likeCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, likeCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadLikeResponseDto')
          ..add('id', id)
          ..add('likeCount', likeCount))
        .toString();
  }
}

class ThreadLikeResponseDtoBuilder
    implements Builder<ThreadLikeResponseDto, ThreadLikeResponseDtoBuilder> {
  _$ThreadLikeResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  num? _likeCount;
  num? get likeCount => _$this._likeCount;
  set likeCount(num? likeCount) => _$this._likeCount = likeCount;

  ThreadLikeResponseDtoBuilder() {
    ThreadLikeResponseDto._defaults(this);
  }

  ThreadLikeResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _likeCount = $v.likeCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadLikeResponseDto other) {
    _$v = other as _$ThreadLikeResponseDto;
  }

  @override
  void update(void Function(ThreadLikeResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadLikeResponseDto build() => _build();

  _$ThreadLikeResponseDto _build() {
    final _$result =
        _$v ??
        _$ThreadLikeResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ThreadLikeResponseDto',
            'id',
          ),
          likeCount: BuiltValueNullFieldError.checkNotNull(
            likeCount,
            r'ThreadLikeResponseDto',
            'likeCount',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
