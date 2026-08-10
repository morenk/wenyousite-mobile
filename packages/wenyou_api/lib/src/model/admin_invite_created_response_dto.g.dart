// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_invite_created_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminInviteCreatedResponseDto extends AdminInviteCreatedResponseDto {
  @override
  final String id;
  @override
  final DateTime expiresAt;

  factory _$AdminInviteCreatedResponseDto([
    void Function(AdminInviteCreatedResponseDtoBuilder)? updates,
  ]) => (AdminInviteCreatedResponseDtoBuilder()..update(updates))._build();

  _$AdminInviteCreatedResponseDto._({required this.id, required this.expiresAt})
    : super._();
  @override
  AdminInviteCreatedResponseDto rebuild(
    void Function(AdminInviteCreatedResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminInviteCreatedResponseDtoBuilder toBuilder() =>
      AdminInviteCreatedResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminInviteCreatedResponseDto &&
        id == other.id &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminInviteCreatedResponseDto')
          ..add('id', id)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class AdminInviteCreatedResponseDtoBuilder
    implements
        Builder<
          AdminInviteCreatedResponseDto,
          AdminInviteCreatedResponseDtoBuilder
        > {
  _$AdminInviteCreatedResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  AdminInviteCreatedResponseDtoBuilder() {
    AdminInviteCreatedResponseDto._defaults(this);
  }

  AdminInviteCreatedResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminInviteCreatedResponseDto other) {
    _$v = other as _$AdminInviteCreatedResponseDto;
  }

  @override
  void update(void Function(AdminInviteCreatedResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminInviteCreatedResponseDto build() => _build();

  _$AdminInviteCreatedResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminInviteCreatedResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'AdminInviteCreatedResponseDto',
            'id',
          ),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
            expiresAt,
            r'AdminInviteCreatedResponseDto',
            'expiresAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
