// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_reply_thread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecentReplyThreadResponseDto extends RecentReplyThreadResponseDto {
  @override
  final String title;

  factory _$RecentReplyThreadResponseDto([
    void Function(RecentReplyThreadResponseDtoBuilder)? updates,
  ]) => (RecentReplyThreadResponseDtoBuilder()..update(updates))._build();

  _$RecentReplyThreadResponseDto._({required this.title}) : super._();
  @override
  RecentReplyThreadResponseDto rebuild(
    void Function(RecentReplyThreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RecentReplyThreadResponseDtoBuilder toBuilder() =>
      RecentReplyThreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecentReplyThreadResponseDto && title == other.title;
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
      r'RecentReplyThreadResponseDto',
    )..add('title', title)).toString();
  }
}

class RecentReplyThreadResponseDtoBuilder
    implements
        Builder<
          RecentReplyThreadResponseDto,
          RecentReplyThreadResponseDtoBuilder
        > {
  _$RecentReplyThreadResponseDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  RecentReplyThreadResponseDtoBuilder() {
    RecentReplyThreadResponseDto._defaults(this);
  }

  RecentReplyThreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecentReplyThreadResponseDto other) {
    _$v = other as _$RecentReplyThreadResponseDto;
  }

  @override
  void update(void Function(RecentReplyThreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecentReplyThreadResponseDto build() => _build();

  _$RecentReplyThreadResponseDto _build() {
    final _$result =
        _$v ??
        _$RecentReplyThreadResponseDto._(
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'RecentReplyThreadResponseDto',
            'title',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
