// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_content_tag_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminContentTagDto extends AdminContentTagDto {
  @override
  final String id;
  @override
  final String name;
  @override
  final bool isActive;

  factory _$AdminContentTagDto([
    void Function(AdminContentTagDtoBuilder)? updates,
  ]) => (AdminContentTagDtoBuilder()..update(updates))._build();

  _$AdminContentTagDto._({
    required this.id,
    required this.name,
    required this.isActive,
  }) : super._();
  @override
  AdminContentTagDto rebuild(
    void Function(AdminContentTagDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminContentTagDtoBuilder toBuilder() =>
      AdminContentTagDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminContentTagDto &&
        id == other.id &&
        name == other.name &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminContentTagDto')
          ..add('id', id)
          ..add('name', name)
          ..add('isActive', isActive))
        .toString();
  }
}

class AdminContentTagDtoBuilder
    implements Builder<AdminContentTagDto, AdminContentTagDtoBuilder> {
  _$AdminContentTagDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  AdminContentTagDtoBuilder() {
    AdminContentTagDto._defaults(this);
  }

  AdminContentTagDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminContentTagDto other) {
    _$v = other as _$AdminContentTagDto;
  }

  @override
  void update(void Function(AdminContentTagDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminContentTagDto build() => _build();

  _$AdminContentTagDto _build() {
    final _$result =
        _$v ??
        _$AdminContentTagDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'AdminContentTagDto',
            'id',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'AdminContentTagDto',
            'name',
          ),
          isActive: BuiltValueNullFieldError.checkNotNull(
            isActive,
            r'AdminContentTagDto',
            'isActive',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
