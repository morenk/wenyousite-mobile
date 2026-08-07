// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_upload_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfirmUploadDto extends ConfirmUploadDto {
  @override
  final String mediaId;

  factory _$ConfirmUploadDto([
    void Function(ConfirmUploadDtoBuilder)? updates,
  ]) => (ConfirmUploadDtoBuilder()..update(updates))._build();

  _$ConfirmUploadDto._({required this.mediaId}) : super._();
  @override
  ConfirmUploadDto rebuild(void Function(ConfirmUploadDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfirmUploadDtoBuilder toBuilder() =>
      ConfirmUploadDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfirmUploadDto && mediaId == other.mediaId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'ConfirmUploadDto',
    )..add('mediaId', mediaId)).toString();
  }
}

class ConfirmUploadDtoBuilder
    implements Builder<ConfirmUploadDto, ConfirmUploadDtoBuilder> {
  _$ConfirmUploadDto? _$v;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  ConfirmUploadDtoBuilder() {
    ConfirmUploadDto._defaults(this);
  }

  ConfirmUploadDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mediaId = $v.mediaId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfirmUploadDto other) {
    _$v = other as _$ConfirmUploadDto;
  }

  @override
  void update(void Function(ConfirmUploadDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfirmUploadDto build() => _build();

  _$ConfirmUploadDto _build() {
    final _$result =
        _$v ??
        _$ConfirmUploadDto._(
          mediaId: BuiltValueNullFieldError.checkNotNull(
            mediaId,
            r'ConfirmUploadDto',
            'mediaId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
