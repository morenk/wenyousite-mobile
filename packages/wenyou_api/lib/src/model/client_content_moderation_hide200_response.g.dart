// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_content_moderation_hide200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ClientContentModerationHide200ResponseCodeEnum
_$clientContentModerationHide200ResponseCodeEnum_number0 =
    const ClientContentModerationHide200ResponseCodeEnum._('number0');
const ClientContentModerationHide200ResponseCodeEnum
_$clientContentModerationHide200ResponseCodeEnum_unknownDefaultOpenApi =
    const ClientContentModerationHide200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

ClientContentModerationHide200ResponseCodeEnum
_$clientContentModerationHide200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$clientContentModerationHide200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$clientContentModerationHide200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$clientContentModerationHide200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ClientContentModerationHide200ResponseCodeEnum>
_$clientContentModerationHide200ResponseCodeEnumValues =
    BuiltSet<ClientContentModerationHide200ResponseCodeEnum>(
      const <ClientContentModerationHide200ResponseCodeEnum>[
        _$clientContentModerationHide200ResponseCodeEnum_number0,
        _$clientContentModerationHide200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ClientContentModerationHide200ResponseCodeEnum>
_$clientContentModerationHide200ResponseCodeEnumSerializer =
    _$ClientContentModerationHide200ResponseCodeEnumSerializer();

class _$ClientContentModerationHide200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<ClientContentModerationHide200ResponseCodeEnum> {
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
    ClientContentModerationHide200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ClientContentModerationHide200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ClientContentModerationHide200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ClientContentModerationHide200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ClientContentModerationHide200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ClientContentModerationHide200Response
    extends ClientContentModerationHide200Response {
  @override
  final AdminContentModerationResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ClientContentModerationHide200Response([
    void Function(ClientContentModerationHide200ResponseBuilder)? updates,
  ]) => (ClientContentModerationHide200ResponseBuilder()..update(updates))
      ._build();

  _$ClientContentModerationHide200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ClientContentModerationHide200Response rebuild(
    void Function(ClientContentModerationHide200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ClientContentModerationHide200ResponseBuilder toBuilder() =>
      ClientContentModerationHide200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientContentModerationHide200Response &&
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
            r'ClientContentModerationHide200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ClientContentModerationHide200ResponseBuilder
    implements
        Builder<
          ClientContentModerationHide200Response,
          ClientContentModerationHide200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ClientContentModerationHide200Response? _$v;

  AdminContentModerationResponseDtoBuilder? _data;
  AdminContentModerationResponseDtoBuilder get data =>
      _$this._data ??= AdminContentModerationResponseDtoBuilder();
  set data(covariant AdminContentModerationResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ClientContentModerationHide200ResponseBuilder() {
    ClientContentModerationHide200Response._defaults(this);
  }

  ClientContentModerationHide200ResponseBuilder get _$this {
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
  void replace(covariant ClientContentModerationHide200Response other) {
    _$v = other as _$ClientContentModerationHide200Response;
  }

  @override
  void update(
    void Function(ClientContentModerationHide200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ClientContentModerationHide200Response build() => _build();

  _$ClientContentModerationHide200Response _build() {
    _$ClientContentModerationHide200Response _$result;
    try {
      _$result =
          _$v ??
          _$ClientContentModerationHide200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ClientContentModerationHide200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ClientContentModerationHide200Response',
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
          r'ClientContentModerationHide200Response',
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
