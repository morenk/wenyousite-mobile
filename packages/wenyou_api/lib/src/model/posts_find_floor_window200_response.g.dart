// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_find_floor_window200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsFindFloorWindow200ResponseCodeEnum
_$postsFindFloorWindow200ResponseCodeEnum_number0 =
    const PostsFindFloorWindow200ResponseCodeEnum._('number0');
const PostsFindFloorWindow200ResponseCodeEnum
_$postsFindFloorWindow200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsFindFloorWindow200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsFindFloorWindow200ResponseCodeEnum
_$postsFindFloorWindow200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$postsFindFloorWindow200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsFindFloorWindow200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsFindFloorWindow200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsFindFloorWindow200ResponseCodeEnum>
_$postsFindFloorWindow200ResponseCodeEnumValues =
    BuiltSet<PostsFindFloorWindow200ResponseCodeEnum>(
      const <PostsFindFloorWindow200ResponseCodeEnum>[
        _$postsFindFloorWindow200ResponseCodeEnum_number0,
        _$postsFindFloorWindow200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsFindFloorWindow200ResponseCodeEnum>
_$postsFindFloorWindow200ResponseCodeEnumSerializer =
    _$PostsFindFloorWindow200ResponseCodeEnumSerializer();

class _$PostsFindFloorWindow200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsFindFloorWindow200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostsFindFloorWindow200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'PostsFindFloorWindow200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsFindFloorWindow200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsFindFloorWindow200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsFindFloorWindow200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsFindFloorWindow200Response
    extends PostsFindFloorWindow200Response {
  @override
  final FloorWindowResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsFindFloorWindow200Response([
    void Function(PostsFindFloorWindow200ResponseBuilder)? updates,
  ]) => (PostsFindFloorWindow200ResponseBuilder()..update(updates))._build();

  _$PostsFindFloorWindow200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsFindFloorWindow200Response rebuild(
    void Function(PostsFindFloorWindow200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsFindFloorWindow200ResponseBuilder toBuilder() =>
      PostsFindFloorWindow200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsFindFloorWindow200Response &&
        data == other.data &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostsFindFloorWindow200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsFindFloorWindow200ResponseBuilder
    implements
        Builder<
          PostsFindFloorWindow200Response,
          PostsFindFloorWindow200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$PostsFindFloorWindow200Response? _$v;

  FloorWindowResponseDtoBuilder? _data;
  FloorWindowResponseDtoBuilder get data =>
      _$this._data ??= FloorWindowResponseDtoBuilder();
  set data(covariant FloorWindowResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  PostsFindFloorWindow200ResponseBuilder() {
    PostsFindFloorWindow200Response._defaults(this);
  }

  PostsFindFloorWindow200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant PostsFindFloorWindow200Response other) {
    _$v = other as _$PostsFindFloorWindow200Response;
  }

  @override
  void update(void Function(PostsFindFloorWindow200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsFindFloorWindow200Response build() => _build();

  _$PostsFindFloorWindow200Response _build() {
    _$PostsFindFloorWindow200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsFindFloorWindow200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsFindFloorWindow200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsFindFloorWindow200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'PostsFindFloorWindow200Response',
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
