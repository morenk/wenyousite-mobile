// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_status_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminStatusResponseDto extends AdminStatusResponseDto {
  @override
  final String name;
  @override
  final String status;
  @override
  final String docs;

  factory _$AdminStatusResponseDto([
    void Function(AdminStatusResponseDtoBuilder)? updates,
  ]) => (AdminStatusResponseDtoBuilder()..update(updates))._build();

  _$AdminStatusResponseDto._({
    required this.name,
    required this.status,
    required this.docs,
  }) : super._();
  @override
  AdminStatusResponseDto rebuild(
    void Function(AdminStatusResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminStatusResponseDtoBuilder toBuilder() =>
      AdminStatusResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminStatusResponseDto &&
        name == other.name &&
        status == other.status &&
        docs == other.docs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, docs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminStatusResponseDto')
          ..add('name', name)
          ..add('status', status)
          ..add('docs', docs))
        .toString();
  }
}

class AdminStatusResponseDtoBuilder
    implements Builder<AdminStatusResponseDto, AdminStatusResponseDtoBuilder> {
  _$AdminStatusResponseDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _docs;
  String? get docs => _$this._docs;
  set docs(String? docs) => _$this._docs = docs;

  AdminStatusResponseDtoBuilder() {
    AdminStatusResponseDto._defaults(this);
  }

  AdminStatusResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _status = $v.status;
      _docs = $v.docs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminStatusResponseDto other) {
    _$v = other as _$AdminStatusResponseDto;
  }

  @override
  void update(void Function(AdminStatusResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminStatusResponseDto build() => _build();

  _$AdminStatusResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminStatusResponseDto._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'AdminStatusResponseDto',
            'name',
          ),
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'AdminStatusResponseDto',
            'status',
          ),
          docs: BuiltValueNullFieldError.checkNotNull(
            docs,
            r'AdminStatusResponseDto',
            'docs',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
