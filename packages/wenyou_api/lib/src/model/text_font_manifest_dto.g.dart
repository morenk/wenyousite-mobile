// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_font_manifest_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TextFontManifestDto extends TextFontManifestDto {
  @override
  final String path;
  @override
  final String sha256;
  @override
  final int bytes;

  factory _$TextFontManifestDto([
    void Function(TextFontManifestDtoBuilder)? updates,
  ]) => (TextFontManifestDtoBuilder()..update(updates))._build();

  _$TextFontManifestDto._({
    required this.path,
    required this.sha256,
    required this.bytes,
  }) : super._();
  @override
  TextFontManifestDto rebuild(
    void Function(TextFontManifestDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TextFontManifestDtoBuilder toBuilder() =>
      TextFontManifestDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TextFontManifestDto &&
        path == other.path &&
        sha256 == other.sha256 &&
        bytes == other.bytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, path.hashCode);
    _$hash = $jc(_$hash, sha256.hashCode);
    _$hash = $jc(_$hash, bytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TextFontManifestDto')
          ..add('path', path)
          ..add('sha256', sha256)
          ..add('bytes', bytes))
        .toString();
  }
}

class TextFontManifestDtoBuilder
    implements Builder<TextFontManifestDto, TextFontManifestDtoBuilder> {
  _$TextFontManifestDto? _$v;

  String? _path;
  String? get path => _$this._path;
  set path(String? path) => _$this._path = path;

  String? _sha256;
  String? get sha256 => _$this._sha256;
  set sha256(String? sha256) => _$this._sha256 = sha256;

  int? _bytes;
  int? get bytes => _$this._bytes;
  set bytes(int? bytes) => _$this._bytes = bytes;

  TextFontManifestDtoBuilder() {
    TextFontManifestDto._defaults(this);
  }

  TextFontManifestDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _path = $v.path;
      _sha256 = $v.sha256;
      _bytes = $v.bytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TextFontManifestDto other) {
    _$v = other as _$TextFontManifestDto;
  }

  @override
  void update(void Function(TextFontManifestDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TextFontManifestDto build() => _build();

  _$TextFontManifestDto _build() {
    final _$result =
        _$v ??
        _$TextFontManifestDto._(
          path: BuiltValueNullFieldError.checkNotNull(
            path,
            r'TextFontManifestDto',
            'path',
          ),
          sha256: BuiltValueNullFieldError.checkNotNull(
            sha256,
            r'TextFontManifestDto',
            'sha256',
          ),
          bytes: BuiltValueNullFieldError.checkNotNull(
            bytes,
            r'TextFontManifestDto',
            'bytes',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
