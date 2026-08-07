// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_unread_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DirectUnreadCountResponseDto extends DirectUnreadCountResponseDto {
  @override
  final num unreadMessageCount;
  @override
  final num pendingRequestCount;
  @override
  final num total;

  factory _$DirectUnreadCountResponseDto([
    void Function(DirectUnreadCountResponseDtoBuilder)? updates,
  ]) => (DirectUnreadCountResponseDtoBuilder()..update(updates))._build();

  _$DirectUnreadCountResponseDto._({
    required this.unreadMessageCount,
    required this.pendingRequestCount,
    required this.total,
  }) : super._();
  @override
  DirectUnreadCountResponseDto rebuild(
    void Function(DirectUnreadCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectUnreadCountResponseDtoBuilder toBuilder() =>
      DirectUnreadCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectUnreadCountResponseDto &&
        unreadMessageCount == other.unreadMessageCount &&
        pendingRequestCount == other.pendingRequestCount &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, unreadMessageCount.hashCode);
    _$hash = $jc(_$hash, pendingRequestCount.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DirectUnreadCountResponseDto')
          ..add('unreadMessageCount', unreadMessageCount)
          ..add('pendingRequestCount', pendingRequestCount)
          ..add('total', total))
        .toString();
  }
}

class DirectUnreadCountResponseDtoBuilder
    implements
        Builder<
          DirectUnreadCountResponseDto,
          DirectUnreadCountResponseDtoBuilder
        > {
  _$DirectUnreadCountResponseDto? _$v;

  num? _unreadMessageCount;
  num? get unreadMessageCount => _$this._unreadMessageCount;
  set unreadMessageCount(num? unreadMessageCount) =>
      _$this._unreadMessageCount = unreadMessageCount;

  num? _pendingRequestCount;
  num? get pendingRequestCount => _$this._pendingRequestCount;
  set pendingRequestCount(num? pendingRequestCount) =>
      _$this._pendingRequestCount = pendingRequestCount;

  num? _total;
  num? get total => _$this._total;
  set total(num? total) => _$this._total = total;

  DirectUnreadCountResponseDtoBuilder() {
    DirectUnreadCountResponseDto._defaults(this);
  }

  DirectUnreadCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _unreadMessageCount = $v.unreadMessageCount;
      _pendingRequestCount = $v.pendingRequestCount;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectUnreadCountResponseDto other) {
    _$v = other as _$DirectUnreadCountResponseDto;
  }

  @override
  void update(void Function(DirectUnreadCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DirectUnreadCountResponseDto build() => _build();

  _$DirectUnreadCountResponseDto _build() {
    final _$result =
        _$v ??
        _$DirectUnreadCountResponseDto._(
          unreadMessageCount: BuiltValueNullFieldError.checkNotNull(
            unreadMessageCount,
            r'DirectUnreadCountResponseDto',
            'unreadMessageCount',
          ),
          pendingRequestCount: BuiltValueNullFieldError.checkNotNull(
            pendingRequestCount,
            r'DirectUnreadCountResponseDto',
            'pendingRequestCount',
          ),
          total: BuiltValueNullFieldError.checkNotNull(
            total,
            r'DirectUnreadCountResponseDto',
            'total',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
