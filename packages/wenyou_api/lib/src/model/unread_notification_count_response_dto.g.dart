// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_notification_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UnreadNotificationCountResponseDto
    extends UnreadNotificationCountResponseDto {
  @override
  final num unreadCount;

  factory _$UnreadNotificationCountResponseDto([
    void Function(UnreadNotificationCountResponseDtoBuilder)? updates,
  ]) => (UnreadNotificationCountResponseDtoBuilder()..update(updates))._build();

  _$UnreadNotificationCountResponseDto._({required this.unreadCount})
    : super._();
  @override
  UnreadNotificationCountResponseDto rebuild(
    void Function(UnreadNotificationCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UnreadNotificationCountResponseDtoBuilder toBuilder() =>
      UnreadNotificationCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UnreadNotificationCountResponseDto &&
        unreadCount == other.unreadCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, unreadCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'UnreadNotificationCountResponseDto',
    )..add('unreadCount', unreadCount)).toString();
  }
}

class UnreadNotificationCountResponseDtoBuilder
    implements
        Builder<
          UnreadNotificationCountResponseDto,
          UnreadNotificationCountResponseDtoBuilder
        > {
  _$UnreadNotificationCountResponseDto? _$v;

  num? _unreadCount;
  num? get unreadCount => _$this._unreadCount;
  set unreadCount(num? unreadCount) => _$this._unreadCount = unreadCount;

  UnreadNotificationCountResponseDtoBuilder() {
    UnreadNotificationCountResponseDto._defaults(this);
  }

  UnreadNotificationCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _unreadCount = $v.unreadCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UnreadNotificationCountResponseDto other) {
    _$v = other as _$UnreadNotificationCountResponseDto;
  }

  @override
  void update(
    void Function(UnreadNotificationCountResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UnreadNotificationCountResponseDto build() => _build();

  _$UnreadNotificationCountResponseDto _build() {
    final _$result =
        _$v ??
        _$UnreadNotificationCountResponseDto._(
          unreadCount: BuiltValueNullFieldError.checkNotNull(
            unreadCount,
            r'UnreadNotificationCountResponseDto',
            'unreadCount',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
