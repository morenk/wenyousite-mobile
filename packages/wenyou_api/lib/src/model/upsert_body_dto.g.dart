// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_body_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpsertBodyDto extends UpsertBodyDto {
  @override
  final String content;
  @override
  final num? version;

  factory _$UpsertBodyDto([void Function(UpsertBodyDtoBuilder)? updates]) =>
      (UpsertBodyDtoBuilder()..update(updates))._build();

  _$UpsertBodyDto._({required this.content, this.version}) : super._();
  @override
  UpsertBodyDto rebuild(void Function(UpsertBodyDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpsertBodyDtoBuilder toBuilder() => UpsertBodyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpsertBodyDto &&
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
    return (newBuiltValueToStringHelper(r'UpsertBodyDto')
          ..add('content', content)
          ..add('version', version))
        .toString();
  }
}

class UpsertBodyDtoBuilder
    implements Builder<UpsertBodyDto, UpsertBodyDtoBuilder> {
  _$UpsertBodyDto? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  UpsertBodyDtoBuilder() {
    UpsertBodyDto._defaults(this);
  }

  UpsertBodyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpsertBodyDto other) {
    _$v = other as _$UpsertBodyDto;
  }

  @override
  void update(void Function(UpsertBodyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpsertBodyDto build() => _build();

  _$UpsertBodyDto _build() {
    final _$result =
        _$v ??
        _$UpsertBodyDto._(
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'UpsertBodyDto',
            'content',
          ),
          version: version,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
