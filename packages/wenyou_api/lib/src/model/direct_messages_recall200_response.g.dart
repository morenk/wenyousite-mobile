// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_messages_recall200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DirectMessagesRecall200ResponseCodeEnum
_$directMessagesRecall200ResponseCodeEnum_number0 =
    const DirectMessagesRecall200ResponseCodeEnum._('number0');
const DirectMessagesRecall200ResponseCodeEnum
_$directMessagesRecall200ResponseCodeEnum_unknownDefaultOpenApi =
    const DirectMessagesRecall200ResponseCodeEnum._('unknownDefaultOpenApi');

DirectMessagesRecall200ResponseCodeEnum
_$directMessagesRecall200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$directMessagesRecall200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$directMessagesRecall200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$directMessagesRecall200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DirectMessagesRecall200ResponseCodeEnum>
_$directMessagesRecall200ResponseCodeEnumValues =
    BuiltSet<DirectMessagesRecall200ResponseCodeEnum>(
      const <DirectMessagesRecall200ResponseCodeEnum>[
        _$directMessagesRecall200ResponseCodeEnum_number0,
        _$directMessagesRecall200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DirectMessagesRecall200ResponseCodeEnum>
_$directMessagesRecall200ResponseCodeEnumSerializer =
    _$DirectMessagesRecall200ResponseCodeEnumSerializer();

class _$DirectMessagesRecall200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<DirectMessagesRecall200ResponseCodeEnum> {
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
    DirectMessagesRecall200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'DirectMessagesRecall200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    DirectMessagesRecall200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DirectMessagesRecall200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DirectMessagesRecall200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DirectMessagesRecall200Response
    extends DirectMessagesRecall200Response {
  @override
  final DirectMessageRecallResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$DirectMessagesRecall200Response([
    void Function(DirectMessagesRecall200ResponseBuilder)? updates,
  ]) => (DirectMessagesRecall200ResponseBuilder()..update(updates))._build();

  _$DirectMessagesRecall200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  DirectMessagesRecall200Response rebuild(
    void Function(DirectMessagesRecall200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectMessagesRecall200ResponseBuilder toBuilder() =>
      DirectMessagesRecall200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectMessagesRecall200Response &&
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
    return (newBuiltValueToStringHelper(r'DirectMessagesRecall200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class DirectMessagesRecall200ResponseBuilder
    implements
        Builder<
          DirectMessagesRecall200Response,
          DirectMessagesRecall200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$DirectMessagesRecall200Response? _$v;

  DirectMessageRecallResponseDtoBuilder? _data;
  DirectMessageRecallResponseDtoBuilder get data =>
      _$this._data ??= DirectMessageRecallResponseDtoBuilder();
  set data(covariant DirectMessageRecallResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  DirectMessagesRecall200ResponseBuilder() {
    DirectMessagesRecall200Response._defaults(this);
  }

  DirectMessagesRecall200ResponseBuilder get _$this {
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
  void replace(covariant DirectMessagesRecall200Response other) {
    _$v = other as _$DirectMessagesRecall200Response;
  }

  @override
  void update(void Function(DirectMessagesRecall200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DirectMessagesRecall200Response build() => _build();

  _$DirectMessagesRecall200Response _build() {
    _$DirectMessagesRecall200Response _$result;
    try {
      _$result =
          _$v ??
          _$DirectMessagesRecall200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'DirectMessagesRecall200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'DirectMessagesRecall200Response',
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
          r'DirectMessagesRecall200Response',
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
