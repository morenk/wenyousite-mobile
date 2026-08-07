// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_search_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminUserSearchResponseDto extends AdminUserSearchResponseDto {
  @override
  final BuiltList<AdminUserSearchItemDto> data;

  factory _$AdminUserSearchResponseDto([
    void Function(AdminUserSearchResponseDtoBuilder)? updates,
  ]) => (AdminUserSearchResponseDtoBuilder()..update(updates))._build();

  _$AdminUserSearchResponseDto._({required this.data}) : super._();
  @override
  AdminUserSearchResponseDto rebuild(
    void Function(AdminUserSearchResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminUserSearchResponseDtoBuilder toBuilder() =>
      AdminUserSearchResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUserSearchResponseDto && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'AdminUserSearchResponseDto',
    )..add('data', data)).toString();
  }
}

class AdminUserSearchResponseDtoBuilder
    implements
        Builder<AdminUserSearchResponseDto, AdminUserSearchResponseDtoBuilder> {
  _$AdminUserSearchResponseDto? _$v;

  ListBuilder<AdminUserSearchItemDto>? _data;
  ListBuilder<AdminUserSearchItemDto> get data =>
      _$this._data ??= ListBuilder<AdminUserSearchItemDto>();
  set data(ListBuilder<AdminUserSearchItemDto>? data) => _$this._data = data;

  AdminUserSearchResponseDtoBuilder() {
    AdminUserSearchResponseDto._defaults(this);
  }

  AdminUserSearchResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUserSearchResponseDto other) {
    _$v = other as _$AdminUserSearchResponseDto;
  }

  @override
  void update(void Function(AdminUserSearchResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUserSearchResponseDto build() => _build();

  _$AdminUserSearchResponseDto _build() {
    _$AdminUserSearchResponseDto _$result;
    try {
      _$result = _$v ?? _$AdminUserSearchResponseDto._(data: data.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminUserSearchResponseDto',
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
