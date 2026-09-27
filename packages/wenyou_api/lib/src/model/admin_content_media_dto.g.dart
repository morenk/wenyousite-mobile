// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_content_media_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminContentMediaDto extends AdminContentMediaDto {
  @override
  final String id;
  @override
  final String url;
  @override
  final MediaDisplayResponseDto? display;

  factory _$AdminContentMediaDto([
    void Function(AdminContentMediaDtoBuilder)? updates,
  ]) => (AdminContentMediaDtoBuilder()..update(updates))._build();

  _$AdminContentMediaDto._({required this.id, required this.url, this.display})
    : super._();
  @override
  AdminContentMediaDto rebuild(
    void Function(AdminContentMediaDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminContentMediaDtoBuilder toBuilder() =>
      AdminContentMediaDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminContentMediaDto &&
        id == other.id &&
        url == other.url &&
        display == other.display;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, display.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminContentMediaDto')
          ..add('id', id)
          ..add('url', url)
          ..add('display', display))
        .toString();
  }
}

class AdminContentMediaDtoBuilder
    implements Builder<AdminContentMediaDto, AdminContentMediaDtoBuilder> {
  _$AdminContentMediaDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  MediaDisplayResponseDtoBuilder? _display;
  MediaDisplayResponseDtoBuilder get display =>
      _$this._display ??= MediaDisplayResponseDtoBuilder();
  set display(MediaDisplayResponseDtoBuilder? display) =>
      _$this._display = display;

  AdminContentMediaDtoBuilder() {
    AdminContentMediaDto._defaults(this);
  }

  AdminContentMediaDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _url = $v.url;
      _display = $v.display?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminContentMediaDto other) {
    _$v = other as _$AdminContentMediaDto;
  }

  @override
  void update(void Function(AdminContentMediaDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminContentMediaDto build() => _build();

  _$AdminContentMediaDto _build() {
    _$AdminContentMediaDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminContentMediaDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'AdminContentMediaDto',
              'id',
            ),
            url: BuiltValueNullFieldError.checkNotNull(
              url,
              r'AdminContentMediaDto',
              'url',
            ),
            display: _display?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'display';
        _display?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminContentMediaDto',
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
