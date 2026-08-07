// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_conversations_mark_read200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectConversationsMarkRead200ResponseCodeEnum
_$directConversationsMarkRead200ResponseCodeEnum_number0 =
    const DirectConversationsMarkRead200ResponseCodeEnum._('number0');
const DirectConversationsMarkRead200ResponseCodeEnum
_$directConversationsMarkRead200ResponseCodeEnum_unknownDefaultOpenApi =
    const DirectConversationsMarkRead200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

DirectConversationsMarkRead200ResponseCodeEnum
_$directConversationsMarkRead200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$directConversationsMarkRead200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$directConversationsMarkRead200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$directConversationsMarkRead200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectConversationsMarkRead200ResponseCodeEnum>
_$directConversationsMarkRead200ResponseCodeEnumValues =
    BuiltSet<DirectConversationsMarkRead200ResponseCodeEnum>(
      const <DirectConversationsMarkRead200ResponseCodeEnum>[
        _$directConversationsMarkRead200ResponseCodeEnum_number0,
        _$directConversationsMarkRead200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DirectConversationsMarkRead200ResponseCodeEnum>
_$directConversationsMarkRead200ResponseCodeEnumSerializer =
    _$DirectConversationsMarkRead200ResponseCodeEnumSerializer();

class _$DirectConversationsMarkRead200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<DirectConversationsMarkRead200ResponseCodeEnum> {
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
    DirectConversationsMarkRead200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'DirectConversationsMarkRead200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationsMarkRead200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectConversationsMarkRead200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectConversationsMarkRead200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectConversationsMarkRead200Response
    extends DirectConversationsMarkRead200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DirectConversationsMarkRead200Response([
    void Function(DirectConversationsMarkRead200ResponseBuilder)? updates,
  ]) => (DirectConversationsMarkRead200ResponseBuilder()..update(updates))
      ._build();

  _$DirectConversationsMarkRead200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DirectConversationsMarkRead200Response rebuild(
    void Function(DirectConversationsMarkRead200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectConversationsMarkRead200ResponseBuilder toBuilder() =>
      DirectConversationsMarkRead200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectConversationsMarkRead200Response &&
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
            r'DirectConversationsMarkRead200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DirectConversationsMarkRead200ResponseBuilder
    implements
        Builder<
          DirectConversationsMarkRead200Response,
          DirectConversationsMarkRead200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$DirectConversationsMarkRead200Response? _$v;

  MessageResponseDtoBuilder? _data;
  MessageResponseDtoBuilder get data =>
      _$this._data ??= MessageResponseDtoBuilder();
  set data(covariant MessageResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DirectConversationsMarkRead200ResponseBuilder() {
    DirectConversationsMarkRead200Response._defaults(this);
  }

  DirectConversationsMarkRead200ResponseBuilder get _$this {
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
  void replace(covariant DirectConversationsMarkRead200Response other) {
    _$v = other as _$DirectConversationsMarkRead200Response;
  }

  @override
  void update(
    void Function(DirectConversationsMarkRead200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  DirectConversationsMarkRead200Response build() => _build();

  _$DirectConversationsMarkRead200Response _build() {
    _$DirectConversationsMarkRead200Response _$result;
    try {
      _$result =
          _$v ??
          _$DirectConversationsMarkRead200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DirectConversationsMarkRead200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DirectConversationsMarkRead200Response',
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
          r'DirectConversationsMarkRead200Response',
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
