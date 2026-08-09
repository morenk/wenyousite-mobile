// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_comment_authors200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsCommentAuthors200ResponseCodeEnum
_$momentsCommentAuthors200ResponseCodeEnum_number0 =
    const MomentsCommentAuthors200ResponseCodeEnum._('number0');
const MomentsCommentAuthors200ResponseCodeEnum
_$momentsCommentAuthors200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsCommentAuthors200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsCommentAuthors200ResponseCodeEnum
_$momentsCommentAuthors200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$momentsCommentAuthors200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsCommentAuthors200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsCommentAuthors200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsCommentAuthors200ResponseCodeEnum>
_$momentsCommentAuthors200ResponseCodeEnumValues =
    BuiltSet<MomentsCommentAuthors200ResponseCodeEnum>(
      const <MomentsCommentAuthors200ResponseCodeEnum>[
        _$momentsCommentAuthors200ResponseCodeEnum_number0,
        _$momentsCommentAuthors200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsCommentAuthors200ResponseCodeEnum>
_$momentsCommentAuthors200ResponseCodeEnumSerializer =
    _$MomentsCommentAuthors200ResponseCodeEnumSerializer();

class _$MomentsCommentAuthors200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsCommentAuthors200ResponseCodeEnum> {
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
    MomentsCommentAuthors200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MomentsCommentAuthors200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsCommentAuthors200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsCommentAuthors200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsCommentAuthors200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsCommentAuthors200Response
    extends MomentsCommentAuthors200Response {
  @override
  final BuiltList<PostAuthorResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsCommentAuthors200Response([
    void Function(MomentsCommentAuthors200ResponseBuilder)? updates,
  ]) => (MomentsCommentAuthors200ResponseBuilder()..update(updates))._build();

  _$MomentsCommentAuthors200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsCommentAuthors200Response rebuild(
    void Function(MomentsCommentAuthors200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsCommentAuthors200ResponseBuilder toBuilder() =>
      MomentsCommentAuthors200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsCommentAuthors200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsCommentAuthors200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsCommentAuthors200ResponseBuilder
    implements
        Builder<
          MomentsCommentAuthors200Response,
          MomentsCommentAuthors200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MomentsCommentAuthors200Response? _$v;

  ListBuilder<PostAuthorResponseDto>? _data;
  ListBuilder<PostAuthorResponseDto> get data =>
      _$this._data ??= ListBuilder<PostAuthorResponseDto>();
  set data(covariant ListBuilder<PostAuthorResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MomentsCommentAuthors200ResponseBuilder() {
    MomentsCommentAuthors200Response._defaults(this);
  }

  MomentsCommentAuthors200ResponseBuilder get _$this {
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
  void replace(covariant MomentsCommentAuthors200Response other) {
    _$v = other as _$MomentsCommentAuthors200Response;
  }

  @override
  void update(void Function(MomentsCommentAuthors200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsCommentAuthors200Response build() => _build();

  _$MomentsCommentAuthors200Response _build() {
    _$MomentsCommentAuthors200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsCommentAuthors200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsCommentAuthors200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsCommentAuthors200Response',
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
          r'MomentsCommentAuthors200Response',
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
