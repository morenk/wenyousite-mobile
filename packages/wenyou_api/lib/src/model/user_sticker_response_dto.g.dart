// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_sticker_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserStickerResponseDto extends UserStickerResponseDto {
  @override
  final String id;
  @override
  final num position;
  @override
  final DateTime? lastUsedAt;
  @override
  final StickerAssetResponseDto asset;
  @override
  final String markdown;

  factory _$UserStickerResponseDto([
    void Function(UserStickerResponseDtoBuilder)? updates,
  ]) => (UserStickerResponseDtoBuilder()..update(updates))._build();

  _$UserStickerResponseDto._({
    required this.id,
    required this.position,
    this.lastUsedAt,
    required this.asset,
    required this.markdown,
  }) : super._();
  @override
  UserStickerResponseDto rebuild(
    void Function(UserStickerResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UserStickerResponseDtoBuilder toBuilder() =>
      UserStickerResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserStickerResponseDto &&
        id == other.id &&
        position == other.position &&
        lastUsedAt == other.lastUsedAt &&
        asset == other.asset &&
        markdown == other.markdown;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, lastUsedAt.hashCode);
    _$hash = $jc(_$hash, asset.hashCode);
    _$hash = $jc(_$hash, markdown.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserStickerResponseDto')
          ..add('id', id)
          ..add('position', position)
          ..add('lastUsedAt', lastUsedAt)
          ..add('asset', asset)
          ..add('markdown', markdown))
        .toString();
  }
}

class UserStickerResponseDtoBuilder
    implements Builder<UserStickerResponseDto, UserStickerResponseDtoBuilder> {
  _$UserStickerResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  num? _position;
  num? get position => _$this._position;
  set position(num? position) => _$this._position = position;

  DateTime? _lastUsedAt;
  DateTime? get lastUsedAt => _$this._lastUsedAt;
  set lastUsedAt(DateTime? lastUsedAt) => _$this._lastUsedAt = lastUsedAt;

  StickerAssetResponseDtoBuilder? _asset;
  StickerAssetResponseDtoBuilder get asset =>
      _$this._asset ??= StickerAssetResponseDtoBuilder();
  set asset(StickerAssetResponseDtoBuilder? asset) => _$this._asset = asset;

  String? _markdown;
  String? get markdown => _$this._markdown;
  set markdown(String? markdown) => _$this._markdown = markdown;

  UserStickerResponseDtoBuilder() {
    UserStickerResponseDto._defaults(this);
  }

  UserStickerResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _position = $v.position;
      _lastUsedAt = $v.lastUsedAt;
      _asset = $v.asset.toBuilder();
      _markdown = $v.markdown;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserStickerResponseDto other) {
    _$v = other as _$UserStickerResponseDto;
  }

  @override
  void update(void Function(UserStickerResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserStickerResponseDto build() => _build();

  _$UserStickerResponseDto _build() {
    _$UserStickerResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$UserStickerResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'UserStickerResponseDto',
              'id',
            ),
            position: BuiltValueNullFieldError.checkNotNull(
              position,
              r'UserStickerResponseDto',
              'position',
            ),
            lastUsedAt: lastUsedAt,
            asset: asset.build(),
            markdown: BuiltValueNullFieldError.checkNotNull(
              markdown,
              r'UserStickerResponseDto',
              'markdown',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'asset';
        asset.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'UserStickerResponseDto',
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
