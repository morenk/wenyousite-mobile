// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreatePostDto extends CreatePostDto {
  @override
  final String content;
  @override
  final String? parentPostId;
  @override
  final String? replyToPostId;
  @override
  final String? clientRequestId;

  factory _$CreatePostDto([void Function(CreatePostDtoBuilder)? updates]) =>
      (CreatePostDtoBuilder()..update(updates))._build();

  _$CreatePostDto._({
    required this.content,
    this.parentPostId,
    this.replyToPostId,
    this.clientRequestId,
  }) : super._();
  @override
  CreatePostDto rebuild(void Function(CreatePostDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreatePostDtoBuilder toBuilder() => CreatePostDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreatePostDto &&
        content == other.content &&
        parentPostId == other.parentPostId &&
        replyToPostId == other.replyToPostId &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, parentPostId.hashCode);
    _$hash = $jc(_$hash, replyToPostId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreatePostDto')
          ..add('content', content)
          ..add('parentPostId', parentPostId)
          ..add('replyToPostId', replyToPostId)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class CreatePostDtoBuilder
    implements Builder<CreatePostDto, CreatePostDtoBuilder> {
  _$CreatePostDto? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _parentPostId;
  String? get parentPostId => _$this._parentPostId;
  set parentPostId(String? parentPostId) => _$this._parentPostId = parentPostId;

  String? _replyToPostId;
  String? get replyToPostId => _$this._replyToPostId;
  set replyToPostId(String? replyToPostId) =>
      _$this._replyToPostId = replyToPostId;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  CreatePostDtoBuilder() {
    CreatePostDto._defaults(this);
  }

  CreatePostDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _parentPostId = $v.parentPostId;
      _replyToPostId = $v.replyToPostId;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreatePostDto other) {
    _$v = other as _$CreatePostDto;
  }

  @override
  void update(void Function(CreatePostDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreatePostDto build() => _build();

  _$CreatePostDto _build() {
    final _$result =
        _$v ??
        _$CreatePostDto._(
          content: BuiltValueNullFieldError.checkNotNull(
            content,
            r'CreatePostDto',
            'content',
          ),
          parentPostId: parentPostId,
          replyToPostId: replyToPostId,
          clientRequestId: clientRequestId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
