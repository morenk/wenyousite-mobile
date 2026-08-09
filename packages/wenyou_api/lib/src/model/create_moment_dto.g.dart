// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_moment_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateMomentDto extends CreateMomentDto {
  @override
  final String title;
  @override
  final String? content;
  @override
  final BuiltList<String> mediaIds;
  @override
  final String? coverMediaId;
  @override
  final String clientRequestId;

  factory _$CreateMomentDto([void Function(CreateMomentDtoBuilder)? updates]) =>
      (CreateMomentDtoBuilder()..update(updates))._build();

  _$CreateMomentDto._({
    required this.title,
    this.content,
    required this.mediaIds,
    this.coverMediaId,
    required this.clientRequestId,
  }) : super._();
  @override
  CreateMomentDto rebuild(void Function(CreateMomentDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateMomentDtoBuilder toBuilder() => CreateMomentDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateMomentDto &&
        title == other.title &&
        content == other.content &&
        mediaIds == other.mediaIds &&
        coverMediaId == other.coverMediaId &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, mediaIds.hashCode);
    _$hash = $jc(_$hash, coverMediaId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateMomentDto')
          ..add('title', title)
          ..add('content', content)
          ..add('mediaIds', mediaIds)
          ..add('coverMediaId', coverMediaId)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class CreateMomentDtoBuilder
    implements Builder<CreateMomentDto, CreateMomentDtoBuilder> {
  _$CreateMomentDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  ListBuilder<String>? _mediaIds;
  ListBuilder<String> get mediaIds =>
      _$this._mediaIds ??= ListBuilder<String>();
  set mediaIds(ListBuilder<String>? mediaIds) => _$this._mediaIds = mediaIds;

  String? _coverMediaId;
  String? get coverMediaId => _$this._coverMediaId;
  set coverMediaId(String? coverMediaId) => _$this._coverMediaId = coverMediaId;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  CreateMomentDtoBuilder() {
    CreateMomentDto._defaults(this);
  }

  CreateMomentDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _content = $v.content;
      _mediaIds = $v.mediaIds.toBuilder();
      _coverMediaId = $v.coverMediaId;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateMomentDto other) {
    _$v = other as _$CreateMomentDto;
  }

  @override
  void update(void Function(CreateMomentDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateMomentDto build() => _build();

  _$CreateMomentDto _build() {
    _$CreateMomentDto _$result;
    try {
      _$result =
          _$v ??
          _$CreateMomentDto._(
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'CreateMomentDto',
              'title',
            ),
            content: content,
            mediaIds: mediaIds.build(),
            coverMediaId: coverMediaId,
            clientRequestId: BuiltValueNullFieldError.checkNotNull(
              clientRequestId,
              r'CreateMomentDto',
              'clientRequestId',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'mediaIds';
        mediaIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CreateMomentDto',
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
