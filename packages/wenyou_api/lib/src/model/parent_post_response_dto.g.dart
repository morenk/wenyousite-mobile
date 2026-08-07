// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_post_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ParentPostResponseDto extends ParentPostResponseDto {
  @override
  final String id;
  @override
  final num? floorNumber;

  factory _$ParentPostResponseDto([
    void Function(ParentPostResponseDtoBuilder)? updates,
  ]) => (ParentPostResponseDtoBuilder()..update(updates))._build();

  _$ParentPostResponseDto._({required this.id, this.floorNumber}) : super._();
  @override
  ParentPostResponseDto rebuild(
    void Function(ParentPostResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ParentPostResponseDtoBuilder toBuilder() =>
      ParentPostResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ParentPostResponseDto &&
        id == other.id &&
        floorNumber == other.floorNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, floorNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ParentPostResponseDto')
          ..add('id', id)
          ..add('floorNumber', floorNumber))
        .toString();
  }
}

class ParentPostResponseDtoBuilder
    implements Builder<ParentPostResponseDto, ParentPostResponseDtoBuilder> {
  _$ParentPostResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  num? _floorNumber;
  num? get floorNumber => _$this._floorNumber;
  set floorNumber(num? floorNumber) => _$this._floorNumber = floorNumber;

  ParentPostResponseDtoBuilder() {
    ParentPostResponseDto._defaults(this);
  }

  ParentPostResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _floorNumber = $v.floorNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ParentPostResponseDto other) {
    _$v = other as _$ParentPostResponseDto;
  }

  @override
  void update(void Function(ParentPostResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ParentPostResponseDto build() => _build();

  _$ParentPostResponseDto _build() {
    final _$result =
        _$v ??
        _$ParentPostResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ParentPostResponseDto',
            'id',
          ),
          floorNumber: floorNumber,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
