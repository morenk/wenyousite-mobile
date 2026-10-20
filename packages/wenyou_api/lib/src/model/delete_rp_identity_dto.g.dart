// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_rp_identity_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteRpIdentityDto extends DeleteRpIdentityDto {
  @override
  final num version;

  factory _$DeleteRpIdentityDto([
    void Function(DeleteRpIdentityDtoBuilder)? updates,
  ]) => (DeleteRpIdentityDtoBuilder()..update(updates))._build();

  _$DeleteRpIdentityDto._({required this.version}) : super._();
  @override
  DeleteRpIdentityDto rebuild(
    void Function(DeleteRpIdentityDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DeleteRpIdentityDtoBuilder toBuilder() =>
      DeleteRpIdentityDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteRpIdentityDto && version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'DeleteRpIdentityDto',
    )..add('version', version)).toString();
  }
}

class DeleteRpIdentityDtoBuilder
    implements Builder<DeleteRpIdentityDto, DeleteRpIdentityDtoBuilder> {
  _$DeleteRpIdentityDto? _$v;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  DeleteRpIdentityDtoBuilder() {
    DeleteRpIdentityDto._defaults(this);
  }

  DeleteRpIdentityDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteRpIdentityDto other) {
    _$v = other as _$DeleteRpIdentityDto;
  }

  @override
  void update(void Function(DeleteRpIdentityDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteRpIdentityDto build() => _build();

  _$DeleteRpIdentityDto _build() {
    final _$result =
        _$v ??
        _$DeleteRpIdentityDto._(
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'DeleteRpIdentityDto',
            'version',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
