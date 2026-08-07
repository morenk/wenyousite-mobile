// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_read_status_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SetReadStatusDto extends SetReadStatusDto {
  @override
  final bool isRead;

  factory _$SetReadStatusDto([
    void Function(SetReadStatusDtoBuilder)? updates,
  ]) => (SetReadStatusDtoBuilder()..update(updates))._build();

  _$SetReadStatusDto._({required this.isRead}) : super._();
  @override
  SetReadStatusDto rebuild(void Function(SetReadStatusDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SetReadStatusDtoBuilder toBuilder() =>
      SetReadStatusDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SetReadStatusDto && isRead == other.isRead;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, isRead.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'SetReadStatusDto',
    )..add('isRead', isRead)).toString();
  }
}

class SetReadStatusDtoBuilder
    implements Builder<SetReadStatusDto, SetReadStatusDtoBuilder> {
  _$SetReadStatusDto? _$v;

  bool? _isRead;
  bool? get isRead => _$this._isRead;
  set isRead(bool? isRead) => _$this._isRead = isRead;

  SetReadStatusDtoBuilder() {
    SetReadStatusDto._defaults(this);
  }

  SetReadStatusDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _isRead = $v.isRead;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SetReadStatusDto other) {
    _$v = other as _$SetReadStatusDto;
  }

  @override
  void update(void Function(SetReadStatusDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SetReadStatusDto build() => _build();

  _$SetReadStatusDto _build() {
    final _$result =
        _$v ??
        _$SetReadStatusDto._(
          isRead: BuiltValueNullFieldError.checkNotNull(
            isRead,
            r'SetReadStatusDto',
            'isRead',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
