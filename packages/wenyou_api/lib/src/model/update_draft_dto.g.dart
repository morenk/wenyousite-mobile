// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_draft_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateDraftDto extends UpdateDraftDto {
  @override
  final String content;
  @override
  final num version;

  factory _$UpdateDraftDto([void Function(UpdateDraftDtoBuilder)? updates]) =>
      (UpdateDraftDtoBuilder()..update(updates))._build();

  _$UpdateDraftDto._({required this.content, required this.version})
    : super._();
  @override
  UpdateDraftDto rebuild(void Function(UpdateDraftDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateDraftDtoBuilder toBuilder() => UpdateDraftDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateDraftDto &&
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
    return (newBuiltValueToStringHelper(r'UpdateDraftDto')
          ..add('content', content)
          ..add('version', version))
        .toString();
  }
}

class UpdateDraftDtoBuilder
    implements Builder<UpdateDraftDto, UpdateDraftDtoBuilder> {
  _$UpdateDraftDto? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  UpdateDraftDtoBuilder() {
    UpdateDraftDto._defaults(this);
  }

  UpdateDraftDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateDraftDto other) {
    _$v = other as _$UpdateDraftDto;
  }

  @override
  void update(void Function(UpdateDraftDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateDraftDto build() => _build();

  _$UpdateDraftDto _build() {
    final _$result =
        _$v ??
        _$UpdateDraftDto._(
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'UpdateDraftDto',
            'content',
          ),
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'UpdateDraftDto',
            'version',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
