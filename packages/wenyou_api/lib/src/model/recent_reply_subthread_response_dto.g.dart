// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_reply_subthread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecentReplySubthreadResponseDto
    extends RecentReplySubthreadResponseDto {
  @override
  final String title;

  factory _$RecentReplySubthreadResponseDto([
    void Function(RecentReplySubthreadResponseDtoBuilder)? updates,
  ]) => (RecentReplySubthreadResponseDtoBuilder()..update(updates))._build();

  _$RecentReplySubthreadResponseDto._({required this.title}) : super._();
  @override
  RecentReplySubthreadResponseDto rebuild(
    void Function(RecentReplySubthreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RecentReplySubthreadResponseDtoBuilder toBuilder() =>
      RecentReplySubthreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecentReplySubthreadResponseDto && title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'RecentReplySubthreadResponseDto',
    )..add('title', title)).toString();
  }
}

class RecentReplySubthreadResponseDtoBuilder
    implements
        Builder<
          RecentReplySubthreadResponseDto,
          RecentReplySubthreadResponseDtoBuilder
        > {
  _$RecentReplySubthreadResponseDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  RecentReplySubthreadResponseDtoBuilder() {
    RecentReplySubthreadResponseDto._defaults(this);
  }

  RecentReplySubthreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecentReplySubthreadResponseDto other) {
    _$v = other as _$RecentReplySubthreadResponseDto;
  }

  @override
  void update(void Function(RecentReplySubthreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecentReplySubthreadResponseDto build() => _build();

  _$RecentReplySubthreadResponseDto _build() {
    final _$result =
        _$v ??
        _$RecentReplySubthreadResponseDto._(
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'RecentReplySubthreadResponseDto',
            'title',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
