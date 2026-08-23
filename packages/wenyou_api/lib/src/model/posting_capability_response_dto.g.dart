// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posting_capability_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostingCapabilityResponseDtoDenialReasonEnum
_$postingCapabilityResponseDtoDenialReasonEnum_AUTHENTICATION_REQUIRED =
    const PostingCapabilityResponseDtoDenialReasonEnum._(
      'AUTHENTICATION_REQUIRED',
    );
const PostingCapabilityResponseDtoDenialReasonEnum
_$postingCapabilityResponseDtoDenialReasonEnum_BLOCKED_RELATION =
    const PostingCapabilityResponseDtoDenialReasonEnum._('BLOCKED_RELATION');
const PostingCapabilityResponseDtoDenialReasonEnum
_$postingCapabilityResponseDtoDenialReasonEnum_COLLABORATOR_REQUIRED =
    const PostingCapabilityResponseDtoDenialReasonEnum._(
      'COLLABORATOR_REQUIRED',
    );
const PostingCapabilityResponseDtoDenialReasonEnum
_$postingCapabilityResponseDtoDenialReasonEnum_PLAYER_REQUIRED =
    const PostingCapabilityResponseDtoDenialReasonEnum._('PLAYER_REQUIRED');
const PostingCapabilityResponseDtoDenialReasonEnum
_$postingCapabilityResponseDtoDenialReasonEnum_unknownDefaultOpenApi =
    const PostingCapabilityResponseDtoDenialReasonEnum._(
      'unknownDefaultOpenApi',
    );

PostingCapabilityResponseDtoDenialReasonEnum
_$postingCapabilityResponseDtoDenialReasonEnumValueOf(String name) {
  switch (name) {
    case 'AUTHENTICATION_REQUIRED':
      return _$postingCapabilityResponseDtoDenialReasonEnum_AUTHENTICATION_REQUIRED;
    case 'BLOCKED_RELATION':
      return _$postingCapabilityResponseDtoDenialReasonEnum_BLOCKED_RELATION;
    case 'COLLABORATOR_REQUIRED':
      return _$postingCapabilityResponseDtoDenialReasonEnum_COLLABORATOR_REQUIRED;
    case 'PLAYER_REQUIRED':
      return _$postingCapabilityResponseDtoDenialReasonEnum_PLAYER_REQUIRED;
    case 'unknownDefaultOpenApi':
      return _$postingCapabilityResponseDtoDenialReasonEnum_unknownDefaultOpenApi;
    default:
      return _$postingCapabilityResponseDtoDenialReasonEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostingCapabilityResponseDtoDenialReasonEnum>
_$postingCapabilityResponseDtoDenialReasonEnumValues =
    BuiltSet<PostingCapabilityResponseDtoDenialReasonEnum>(
      const <PostingCapabilityResponseDtoDenialReasonEnum>[
        _$postingCapabilityResponseDtoDenialReasonEnum_AUTHENTICATION_REQUIRED,
        _$postingCapabilityResponseDtoDenialReasonEnum_BLOCKED_RELATION,
        _$postingCapabilityResponseDtoDenialReasonEnum_COLLABORATOR_REQUIRED,
        _$postingCapabilityResponseDtoDenialReasonEnum_PLAYER_REQUIRED,
        _$postingCapabilityResponseDtoDenialReasonEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostingCapabilityResponseDtoDenialReasonEnum>
_$postingCapabilityResponseDtoDenialReasonEnumSerializer =
    _$PostingCapabilityResponseDtoDenialReasonEnumSerializer();

class _$PostingCapabilityResponseDtoDenialReasonEnumSerializer
    implements
        PrimitiveSerializer<PostingCapabilityResponseDtoDenialReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'AUTHENTICATION_REQUIRED': 'AUTHENTICATION_REQUIRED',
    'BLOCKED_RELATION': 'BLOCKED_RELATION',
    'COLLABORATOR_REQUIRED': 'COLLABORATOR_REQUIRED',
    'PLAYER_REQUIRED': 'PLAYER_REQUIRED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'AUTHENTICATION_REQUIRED': 'AUTHENTICATION_REQUIRED',
    'BLOCKED_RELATION': 'BLOCKED_RELATION',
    'COLLABORATOR_REQUIRED': 'COLLABORATOR_REQUIRED',
    'PLAYER_REQUIRED': 'PLAYER_REQUIRED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostingCapabilityResponseDtoDenialReasonEnum,
  ];
  @override
  final String wireName = 'PostingCapabilityResponseDtoDenialReasonEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostingCapabilityResponseDtoDenialReasonEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostingCapabilityResponseDtoDenialReasonEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostingCapabilityResponseDtoDenialReasonEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostingCapabilityResponseDto extends PostingCapabilityResponseDto {
  @override
  final bool canPost;
  @override
  final PostingCapabilityResponseDtoDenialReasonEnum? denialReason;

  factory _$PostingCapabilityResponseDto([
    void Function(PostingCapabilityResponseDtoBuilder)? updates,
  ]) => (PostingCapabilityResponseDtoBuilder()..update(updates))._build();

  _$PostingCapabilityResponseDto._({required this.canPost, this.denialReason})
    : super._();
  @override
  PostingCapabilityResponseDto rebuild(
    void Function(PostingCapabilityResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostingCapabilityResponseDtoBuilder toBuilder() =>
      PostingCapabilityResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostingCapabilityResponseDto &&
        canPost == other.canPost &&
        denialReason == other.denialReason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, canPost.hashCode);
    _$hash = $jc(_$hash, denialReason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostingCapabilityResponseDto')
          ..add('canPost', canPost)
          ..add('denialReason', denialReason))
        .toString();
  }
}

class PostingCapabilityResponseDtoBuilder
    implements
        Builder<
          PostingCapabilityResponseDto,
          PostingCapabilityResponseDtoBuilder
        > {
  _$PostingCapabilityResponseDto? _$v;

  bool? _canPost;
  bool? get canPost => _$this._canPost;
  set canPost(bool? canPost) => _$this._canPost = canPost;

  PostingCapabilityResponseDtoDenialReasonEnum? _denialReason;
  PostingCapabilityResponseDtoDenialReasonEnum? get denialReason =>
      _$this._denialReason;
  set denialReason(
    PostingCapabilityResponseDtoDenialReasonEnum? denialReason,
  ) => _$this._denialReason = denialReason;

  PostingCapabilityResponseDtoBuilder() {
    PostingCapabilityResponseDto._defaults(this);
  }

  PostingCapabilityResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _canPost = $v.canPost;
      _denialReason = $v.denialReason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostingCapabilityResponseDto other) {
    _$v = other as _$PostingCapabilityResponseDto;
  }

  @override
  void update(void Function(PostingCapabilityResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostingCapabilityResponseDto build() => _build();

  _$PostingCapabilityResponseDto _build() {
    final _$result =
        _$v ??
        _$PostingCapabilityResponseDto._(
          canPost: BuiltValueNullFieldError.checkNotNull(
            canPost,
            r'PostingCapabilityResponseDto',
            'canPost',
          ),
          denialReason: denialReason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
