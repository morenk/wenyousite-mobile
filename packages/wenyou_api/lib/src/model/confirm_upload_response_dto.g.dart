// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_upload_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfirmUploadResponseDto extends ConfirmUploadResponseDto {
  @override
  final MediaResponseDto media;
  @override
  final bool processing;

  factory _$ConfirmUploadResponseDto([
    void Function(ConfirmUploadResponseDtoBuilder)? updates,
  ]) => (ConfirmUploadResponseDtoBuilder()..update(updates))._build();

  _$ConfirmUploadResponseDto._({required this.media, required this.processing})
    : super._();
  @override
  ConfirmUploadResponseDto rebuild(
    void Function(ConfirmUploadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ConfirmUploadResponseDtoBuilder toBuilder() =>
      ConfirmUploadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfirmUploadResponseDto &&
        media == other.media &&
        processing == other.processing;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, media.hashCode);
    _$hash = $jc(_$hash, processing.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfirmUploadResponseDto')
          ..add('media', media)
          ..add('processing', processing))
        .toString();
  }
}

class ConfirmUploadResponseDtoBuilder
    implements
        Builder<ConfirmUploadResponseDto, ConfirmUploadResponseDtoBuilder> {
  _$ConfirmUploadResponseDto? _$v;

  MediaResponseDtoBuilder? _media;
  MediaResponseDtoBuilder get media =>
      _$this._media ??= MediaResponseDtoBuilder();
  set media(MediaResponseDtoBuilder? media) => _$this._media = media;

  bool? _processing;
  bool? get processing => _$this._processing;
  set processing(bool? processing) => _$this._processing = processing;

  ConfirmUploadResponseDtoBuilder() {
    ConfirmUploadResponseDto._defaults(this);
  }

  ConfirmUploadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _media = $v.media.toBuilder();
      _processing = $v.processing;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfirmUploadResponseDto other) {
    _$v = other as _$ConfirmUploadResponseDto;
  }

  @override
  void update(void Function(ConfirmUploadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfirmUploadResponseDto build() => _build();

  _$ConfirmUploadResponseDto _build() {
    _$ConfirmUploadResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ConfirmUploadResponseDto._(
            media: media.build(),
            processing: BuiltValueNullFieldError.checkNotNull(
              processing,
              r'ConfirmUploadResponseDto',
              'processing',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'media';
        media.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ConfirmUploadResponseDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
