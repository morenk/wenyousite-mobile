// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_activity_summary_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserActivitySummaryResponseDto extends UserActivitySummaryResponseDto {
  @override
  final num momentCount;
  @override
  final num createdThreadCount;
  @override
  final num? playedThreadCount;
  @override
  final num? replyCount;

  factory _$UserActivitySummaryResponseDto([
    void Function(UserActivitySummaryResponseDtoBuilder)? updates,
  ]) => (UserActivitySummaryResponseDtoBuilder()..update(updates))._build();

  _$UserActivitySummaryResponseDto._({
    required this.momentCount,
    required this.createdThreadCount,
    this.playedThreadCount,
    this.replyCount,
  }) : super._();
  @override
  UserActivitySummaryResponseDto rebuild(
    void Function(UserActivitySummaryResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UserActivitySummaryResponseDtoBuilder toBuilder() =>
      UserActivitySummaryResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserActivitySummaryResponseDto &&
        momentCount == other.momentCount &&
        createdThreadCount == other.createdThreadCount &&
        playedThreadCount == other.playedThreadCount &&
        replyCount == other.replyCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, momentCount.hashCode);
    _$hash = $jc(_$hash, createdThreadCount.hashCode);
    _$hash = $jc(_$hash, playedThreadCount.hashCode);
    _$hash = $jc(_$hash, replyCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserActivitySummaryResponseDto')
          ..add('momentCount', momentCount)
          ..add('createdThreadCount', createdThreadCount)
          ..add('playedThreadCount', playedThreadCount)
          ..add('replyCount', replyCount))
        .toString();
  }
}

class UserActivitySummaryResponseDtoBuilder
    implements
        Builder<
          UserActivitySummaryResponseDto,
          UserActivitySummaryResponseDtoBuilder
        > {
  _$UserActivitySummaryResponseDto? _$v;

  num? _momentCount;
  num? get momentCount => _$this._momentCount;
  set momentCount(num? momentCount) => _$this._momentCount = momentCount;

  num? _createdThreadCount;
  num? get createdThreadCount => _$this._createdThreadCount;
  set createdThreadCount(num? createdThreadCount) =>
      _$this._createdThreadCount = createdThreadCount;

  num? _playedThreadCount;
  num? get playedThreadCount => _$this._playedThreadCount;
  set playedThreadCount(num? playedThreadCount) =>
      _$this._playedThreadCount = playedThreadCount;

  num? _replyCount;
  num? get replyCount => _$this._replyCount;
  set replyCount(num? replyCount) => _$this._replyCount = replyCount;

  UserActivitySummaryResponseDtoBuilder() {
    UserActivitySummaryResponseDto._defaults(this);
  }

  UserActivitySummaryResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _momentCount = $v.momentCount;
      _createdThreadCount = $v.createdThreadCount;
      _playedThreadCount = $v.playedThreadCount;
      _replyCount = $v.replyCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserActivitySummaryResponseDto other) {
    _$v = other as _$UserActivitySummaryResponseDto;
  }

  @override
  void update(void Function(UserActivitySummaryResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserActivitySummaryResponseDto build() => _build();

  _$UserActivitySummaryResponseDto _build() {
    final _$result =
        _$v ??
        _$UserActivitySummaryResponseDto._(
          momentCount: BuiltValueNullFieldError.checkNotNull(
            momentCount,
            r'UserActivitySummaryResponseDto',
            'momentCount',
          ),
          createdThreadCount: BuiltValueNullFieldError.checkNotNull(
            createdThreadCount,
            r'UserActivitySummaryResponseDto',
            'createdThreadCount',
          ),
          playedThreadCount: playedThreadCount,
          replyCount: replyCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
