// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_admin_invite_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateAdminInviteDto extends CreateAdminInviteDto {
  @override
  final String userId;

  factory _$CreateAdminInviteDto([
    void Function(CreateAdminInviteDtoBuilder)? updates,
  ]) => (CreateAdminInviteDtoBuilder()..update(updates))._build();

  _$CreateAdminInviteDto._({required this.userId}) : super._();
  @override
  CreateAdminInviteDto rebuild(
    void Function(CreateAdminInviteDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateAdminInviteDtoBuilder toBuilder() =>
      CreateAdminInviteDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateAdminInviteDto && userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'CreateAdminInviteDto',
    )..add('userId', userId)).toString();
  }
}

class CreateAdminInviteDtoBuilder
    implements Builder<CreateAdminInviteDto, CreateAdminInviteDtoBuilder> {
  _$CreateAdminInviteDto? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  CreateAdminInviteDtoBuilder() {
    CreateAdminInviteDto._defaults(this);
  }

  CreateAdminInviteDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateAdminInviteDto other) {
    _$v = other as _$CreateAdminInviteDto;
  }

  @override
  void update(void Function(CreateAdminInviteDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateAdminInviteDto build() => _build();

  _$CreateAdminInviteDto _build() {
    final _$result =
        _$v ??
        _$CreateAdminInviteDto._(
          userId: BuiltValueNullFieldError.checkNotNull(
            userId,
            r'CreateAdminInviteDto',
            'userId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
