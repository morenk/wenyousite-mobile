// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversations_handle_request200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationsHandleRequest200ResponseCodeEnum
_$directConversationsHandleRequest200ResponseCodeEnum_number0 =
    const DirectConversationsHandleRequest200ResponseCodeEnum._('number0');
const DirectConversationsHandleRequest200ResponseCodeEnum
_$directConversationsHandleRequest200ResponseCodeEnum_unknownDefaultOpenApi =
    const DirectConversationsHandleRequest200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

DirectConversationsHandleRequest200ResponseCodeEnum
_$directConversationsHandleRequest200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$directConversationsHandleRequest200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$directConversationsHandleRequest200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationsHandleRequest200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationsHandleRequest200ResponseCodeEnum>
_$directConversationsHandleRequest200ResponseCodeEnumValues =
    BuiltSet<DirectConversationsHandleRequest200ResponseCodeEnum>(const <
      DirectConversationsHandleRequest200ResponseCodeEnum
    >[
      _$directConversationsHandleRequest200ResponseCodeEnum_number0,
      _$directConversationsHandleRequest200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<DirectConversationsHandleRequest200ResponseCodeEnum>
_$directConversationsHandleRequest200ResponseCodeEnumSerializer =
    _$DirectConversationsHandleRequest200ResponseCodeEnumSerializer();

class _$DirectConversationsHandleRequest200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<
          DirectConversationsHandleRequest200ResponseCodeEnum
        > {
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
    DirectConversationsHandleRequest200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'DirectConversationsHandleRequest200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationsHandleRequest200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationsHandleRequest200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationsHandleRequest200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationsHandleRequest200Response
    extends DirectConversationsHandleRequest200Response {
  @override
  final DirectConversationResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DirectConversationsHandleRequest200Response([
    void Function(DirectConversationsHandleRequest200ResponseBuilder)? updates,
  ]) => (DirectConversationsHandleRequest200ResponseBuilder()..update(updates))
      ._build();

  _$DirectConversationsHandleRequest200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DirectConversationsHandleRequest200Response rebuild(
    void Function(DirectConversationsHandleRequest200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationsHandleRequest200ResponseBuilder toBuilder() =>
      DirectConversationsHandleRequest200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationsHandleRequest200Response &&
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
    return (newBuiltValueToStringHelper(
            r'DirectConversationsHandleRequest200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DirectConversationsHandleRequest200ResponseBuilder
    implements
        Builder<
          DirectConversationsHandleRequest200Response,
          DirectConversationsHandleRequest200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$DirectConversationsHandleRequest200Response? _$v;

  DirectConversationResponseDtoBuilder? _data;
  DirectConversationResponseDtoBuilder get data =>
      _$this._data ??= DirectConversationResponseDtoBuilder();
  set data(covariant DirectConversationResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DirectConversationsHandleRequest200ResponseBuilder() {
    DirectConversationsHandleRequest200Response._defaults(this);
  }

  DirectConversationsHandleRequest200ResponseBuilder get _$this {
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
  void replace(covariant DirectConversationsHandleRequest200Response other) {
    _$v = other as _$DirectConversationsHandleRequest200Response;
  }

  @override
  void update(
    void Function(DirectConversationsHandleRequest200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationsHandleRequest200Response build() => _build();

  _$DirectConversationsHandleRequest200Response _build() {
    _$DirectConversationsHandleRequest200Response _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationsHandleRequest200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DirectConversationsHandleRequest200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DirectConversationsHandleRequest200Response',
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
          r'DirectConversationsHandleRequest200Response',
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
