// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_system_notification_history_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminSystemNotificationHistoryResponseDto
    extends AdminSystemNotificationHistoryResponseDto {
  @override
  final BuiltList<AdminSystemNotificationHistoryItemDto> data;
  @override
  final String? cursor;
  @override
  final bool hasMore;

  factory _$AdminSystemNotificationHistoryResponseDto([
    void Function(AdminSystemNotificationHistoryResponseDtoBuilder)? updates,
  ]) => (AdminSystemNotificationHistoryResponseDtoBuilder()..update(updates))
      ._build();

  _$AdminSystemNotificationHistoryResponseDto._({
    required this.data,
    this.cursor,
    required this.hasMore,
  }) : super._();
  @override
  AdminSystemNotificationHistoryResponseDto rebuild(
    void Function(AdminSystemNotificationHistoryResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminSystemNotificationHistoryResponseDtoBuilder toBuilder() =>
      AdminSystemNotificationHistoryResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminSystemNotificationHistoryResponseDto &&
        data == other.data &&
        cursor == other.cursor &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, cursor.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminSystemNotificationHistoryResponseDto',
          )
          ..add('data', data)
          ..add('cursor', cursor)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class AdminSystemNotificationHistoryResponseDtoBuilder
    implements
        Builder<
          AdminSystemNotificationHistoryResponseDto,
          AdminSystemNotificationHistoryResponseDtoBuilder
        > {
  _$AdminSystemNotificationHistoryResponseDto? _$v;

  ListBuilder<AdminSystemNotificationHistoryItemDto>? _data;
  ListBuilder<AdminSystemNotificationHistoryItemDto> get data =>
      _$this._data ??= ListBuilder<AdminSystemNotificationHistoryItemDto>();
  set data(ListBuilder<AdminSystemNotificationHistoryItemDto>? data) =>
      _$this._data = data;

  String? _cursor;
  String? get cursor => _$this._cursor;
  set cursor(String? cursor) => _$this._cursor = cursor;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  AdminSystemNotificationHistoryResponseDtoBuilder() {
    AdminSystemNotificationHistoryResponseDto._defaults(this);
  }

  AdminSystemNotificationHistoryResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _cursor = $v.cursor;
      _hasMore = $v.hasMore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminSystemNotificationHistoryResponseDto other) {
    _$v = other as _$AdminSystemNotificationHistoryResponseDto;
  }

  @override
  void update(
    void Function(AdminSystemNotificationHistoryResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminSystemNotificationHistoryResponseDto build() => _build();

  _$AdminSystemNotificationHistoryResponseDto _build() {
    _$AdminSystemNotificationHistoryResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminSystemNotificationHistoryResponseDto._(
            data: data.build(),
            cursor: cursor,
            hasMore: BuiltValueNullFieldError.checkNotNull(
              hasMore,
              r'AdminSystemNotificationHistoryResponseDto',
              'hasMore',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminSystemNotificationHistoryResponseDto',
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
