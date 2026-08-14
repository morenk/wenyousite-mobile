// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_hidden_content_user_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminHiddenContentUserResponseDto
    extends AdminHiddenContentUserResponseDto {
  @override
  final String id;
  @override
  final String username;

  factory _$AdminHiddenContentUserResponseDto([
    void Function(AdminHiddenContentUserResponseDtoBuilder)? updates,
  ]) => (AdminHiddenContentUserResponseDtoBuilder()..update(updates))._build();

  _$AdminHiddenContentUserResponseDto._({
    required this.id,
    required this.username,
  }) : super._();
  @override
  AdminHiddenContentUserResponseDto rebuild(
    void Function(AdminHiddenContentUserResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminHiddenContentUserResponseDtoBuilder toBuilder() =>
      AdminHiddenContentUserResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminHiddenContentUserResponseDto &&
        id == other.id &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminHiddenContentUserResponseDto')
          ..add('id', id)
          ..add('username', username))
        .toString();
  }
}

class AdminHiddenContentUserResponseDtoBuilder
    implements
        Builder<
          AdminHiddenContentUserResponseDto,
          AdminHiddenContentUserResponseDtoBuilder
        > {
  _$AdminHiddenContentUserResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  AdminHiddenContentUserResponseDtoBuilder() {
    AdminHiddenContentUserResponseDto._defaults(this);
  }

  AdminHiddenContentUserResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminHiddenContentUserResponseDto other) {
    _$v = other as _$AdminHiddenContentUserResponseDto;
  }

  @override
  void update(
    void Function(AdminHiddenContentUserResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminHiddenContentUserResponseDto build() => _build();

  _$AdminHiddenContentUserResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminHiddenContentUserResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'AdminHiddenContentUserResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'AdminHiddenContentUserResponseDto',
            'username',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
