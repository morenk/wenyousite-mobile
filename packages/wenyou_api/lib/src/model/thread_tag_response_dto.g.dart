// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_tag_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadTagResponseDto extends ThreadTagResponseDto {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? color;

  factory _$ThreadTagResponseDto([
    void Function(ThreadTagResponseDtoBuilder)? updates,
  ]) => (ThreadTagResponseDtoBuilder()..update(updates))._build();

  _$ThreadTagResponseDto._({required this.id, required this.name, this.color})
    : super._();
  @override
  ThreadTagResponseDto rebuild(
    void Function(ThreadTagResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadTagResponseDtoBuilder toBuilder() =>
      ThreadTagResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadTagResponseDto &&
        id == other.id &&
        name == other.name &&
        color == other.color;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadTagResponseDto')
          ..add('id', id)
          ..add('name', name)
          ..add('color', color))
        .toString();
  }
}

class ThreadTagResponseDtoBuilder
    implements Builder<ThreadTagResponseDto, ThreadTagResponseDtoBuilder> {
  _$ThreadTagResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _color;
  String? get color => _$this._color;
  set color(String? color) => _$this._color = color;

  ThreadTagResponseDtoBuilder() {
    ThreadTagResponseDto._defaults(this);
  }

  ThreadTagResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _color = $v.color;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadTagResponseDto other) {
    _$v = other as _$ThreadTagResponseDto;
  }

  @override
  void update(void Function(ThreadTagResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadTagResponseDto build() => _build();

  _$ThreadTagResponseDto _build() {
    final _$result =
        _$v ??
        _$ThreadTagResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ThreadTagResponseDto',
            'id',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'ThreadTagResponseDto',
            'name',
          ),
          color: color,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
