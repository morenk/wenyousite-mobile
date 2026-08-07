// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_post_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdatePostDto extends UpdatePostDto {
  @override
  final String content;
  @override
  final num version;

  factory _$UpdatePostDto([void Function(UpdatePostDtoBuilder)? updates]) =>
      (UpdatePostDtoBuilder()..update(updates))._build();

  _$UpdatePostDto._({required this.content, required this.version}) : super._();
  @override
  UpdatePostDto rebuild(void Function(UpdatePostDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdatePostDtoBuilder toBuilder() => UpdatePostDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdatePostDto &&
        content == other.content &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdatePostDto')
          ..add('content', content)
          ..add('version', version))
        .toString();
  }
}

class UpdatePostDtoBuilder
    implements Builder<UpdatePostDto, UpdatePostDtoBuilder> {
  _$UpdatePostDto? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  UpdatePostDtoBuilder() {
    UpdatePostDto._defaults(this);
  }

  UpdatePostDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdatePostDto other) {
    _$v = other as _$UpdatePostDto;
  }

  @override
  void update(void Function(UpdatePostDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdatePostDto build() => _build();

  _$UpdatePostDto _build() {
    final _$result =
        _$v ??
        _$UpdatePostDto._(
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'UpdatePostDto',
            'content',
          ),
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'UpdatePostDto',
            'version',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
