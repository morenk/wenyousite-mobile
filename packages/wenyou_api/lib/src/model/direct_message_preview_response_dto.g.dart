// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message_preview_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DirectMessagePreviewResponseDto
    extends DirectMessagePreviewResponseDto {
  @override
  final String id;
  @override
  final String senderId;
  @override
  final String? contentPreview;
  @override
  final bool hasImage;
  @override
  final bool hasSticker;
  @override
  final bool isRecalled;
  @override
  final DateTime createdAt;

  factory _$DirectMessagePreviewResponseDto([
    void Function(DirectMessagePreviewResponseDtoBuilder)? updates,
  ]) => (DirectMessagePreviewResponseDtoBuilder()..update(updates))._build();

  _$DirectMessagePreviewResponseDto._({
    required this.id,
    required this.senderId,
    this.contentPreview,
    required this.hasImage,
    required this.hasSticker,
    required this.isRecalled,
    required this.createdAt,
  }) : super._();
  @override
  DirectMessagePreviewResponseDto rebuild(
    void Function(DirectMessagePreviewResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectMessagePreviewResponseDtoBuilder toBuilder() =>
      DirectMessagePreviewResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectMessagePreviewResponseDto &&
        id == other.id &&
        senderId == other.senderId &&
        contentPreview == other.contentPreview &&
        hasImage == other.hasImage &&
        hasSticker == other.hasSticker &&
        isRecalled == other.isRecalled &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, senderId.hashCode);
    _$hash = $jc(_$hash, contentPreview.hashCode);
    _$hash = $jc(_$hash, hasImage.hashCode);
    _$hash = $jc(_$hash, hasSticker.hashCode);
    _$hash = $jc(_$hash, isRecalled.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DirectMessagePreviewResponseDto')
          ..add('id', id)
          ..add('senderId', senderId)
          ..add('contentPreview', contentPreview)
          ..add('hasImage', hasImage)
          ..add('hasSticker', hasSticker)
          ..add('isRecalled', isRecalled)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class DirectMessagePreviewResponseDtoBuilder
    implements
        Builder<
          DirectMessagePreviewResponseDto,
          DirectMessagePreviewResponseDtoBuilder
        > {
  _$DirectMessagePreviewResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _senderId;
  String? get senderId => _$this._senderId;
  set senderId(String? senderId) => _$this._senderId = senderId;

  String? _contentPreview;
  String? get contentPreview => _$this._contentPreview;
  set contentPreview(String? contentPreview) =>
      _$this._contentPreview = contentPreview;

  bool? _hasImage;
  bool? get hasImage => _$this._hasImage;
  set hasImage(bool? hasImage) => _$this._hasImage = hasImage;

  bool? _hasSticker;
  bool? get hasSticker => _$this._hasSticker;
  set hasSticker(bool? hasSticker) => _$this._hasSticker = hasSticker;

  bool? _isRecalled;
  bool? get isRecalled => _$this._isRecalled;
  set isRecalled(bool? isRecalled) => _$this._isRecalled = isRecalled;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DirectMessagePreviewResponseDtoBuilder() {
    DirectMessagePreviewResponseDto._defaults(this);
  }

  DirectMessagePreviewResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _senderId = $v.senderId;
      _contentPreview = $v.contentPreview;
      _hasImage = $v.hasImage;
      _hasSticker = $v.hasSticker;
      _isRecalled = $v.isRecalled;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectMessagePreviewResponseDto other) {
    _$v = other as _$DirectMessagePreviewResponseDto;
  }

  @override
  void update(void Function(DirectMessagePreviewResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DirectMessagePreviewResponseDto build() => _build();

  _$DirectMessagePreviewResponseDto _build() {
    final _$result =
        _$v ??
        _$DirectMessagePreviewResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'DirectMessagePreviewResponseDto',
            'id',
          ),
          senderId: BuiltValueNullFieldError.checkNotNull(
            senderId,
            r'DirectMessagePreviewResponseDto',
            'senderId',
          ),
          contentPreview: contentPreview,
          hasImage: BuiltValueNullFieldError.checkNotNull(
            hasImage,
            r'DirectMessagePreviewResponseDto',
            'hasImage',
          ),
          hasSticker: BuiltValueNullFieldError.checkNotNull(
            hasSticker,
            r'DirectMessagePreviewResponseDto',
            'hasSticker',
          ),
          isRecalled: BuiltValueNullFieldError.checkNotNull(
            isRecalled,
            r'DirectMessagePreviewResponseDto',
            'isRecalled',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'DirectMessagePreviewResponseDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
