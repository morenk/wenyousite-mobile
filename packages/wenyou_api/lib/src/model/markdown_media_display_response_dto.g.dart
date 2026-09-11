// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markdown_media_display_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MarkdownMediaDisplayResponseDto
    extends MarkdownMediaDisplayResponseDto {
  @override
  final String sourceUrl;
  @override
  final MediaDisplayResponseDto? display;

  factory _$MarkdownMediaDisplayResponseDto([
    void Function(MarkdownMediaDisplayResponseDtoBuilder)? updates,
  ]) => (MarkdownMediaDisplayResponseDtoBuilder()..update(updates))._build();

  _$MarkdownMediaDisplayResponseDto._({required this.sourceUrl, this.display})
    : super._();
  @override
  MarkdownMediaDisplayResponseDto rebuild(
    void Function(MarkdownMediaDisplayResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MarkdownMediaDisplayResponseDtoBuilder toBuilder() =>
      MarkdownMediaDisplayResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MarkdownMediaDisplayResponseDto &&
        sourceUrl == other.sourceUrl &&
        display == other.display;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sourceUrl.hashCode);
    _$hash = $jc(_$hash, display.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MarkdownMediaDisplayResponseDto')
          ..add('sourceUrl', sourceUrl)
          ..add('display', display))
        .toString();
  }
}

class MarkdownMediaDisplayResponseDtoBuilder
    implements
        Builder<
          MarkdownMediaDisplayResponseDto,
          MarkdownMediaDisplayResponseDtoBuilder
        > {
  _$MarkdownMediaDisplayResponseDto? _$v;

  String? _sourceUrl;
  String? get sourceUrl => _$this._sourceUrl;
  set sourceUrl(String? sourceUrl) => _$this._sourceUrl = sourceUrl;

  MediaDisplayResponseDtoBuilder? _display;
  MediaDisplayResponseDtoBuilder get display =>
      _$this._display ??= MediaDisplayResponseDtoBuilder();
  set display(MediaDisplayResponseDtoBuilder? display) =>
      _$this._display = display;

  MarkdownMediaDisplayResponseDtoBuilder() {
    MarkdownMediaDisplayResponseDto._defaults(this);
  }

  MarkdownMediaDisplayResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sourceUrl = $v.sourceUrl;
      _display = $v.display?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MarkdownMediaDisplayResponseDto other) {
    _$v = other as _$MarkdownMediaDisplayResponseDto;
  }

  @override
  void update(void Function(MarkdownMediaDisplayResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MarkdownMediaDisplayResponseDto build() => _build();

  _$MarkdownMediaDisplayResponseDto _build() {
    _$MarkdownMediaDisplayResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$MarkdownMediaDisplayResponseDto._(
            sourceUrl: BuiltValueNullFieldError.checkNotNull(
              sourceUrl,
              r'MarkdownMediaDisplayResponseDto',
              'sourceUrl',
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
          r'MarkdownMediaDisplayResponseDto',
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
